import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/mewtionary_theme.dart';
import '../models/engagement_models.dart';
import '../services/engagement_content_service.dart';
import '../services/gamification_service.dart';
import '../services/listening_lab_service.dart';
import '../services/student_profile_service.dart';
import '../services/learning_feedback_service.dart';
import '../widgets/learning_feedback_anchor.dart';

class ListeningLabScreen extends StatefulWidget {
  const ListeningLabScreen({
    required this.content,
    required this.listening,
    required this.gamification,
    required this.profile,
    required this.teacher,
    super.key,
  });

  final EngagementContentService content;
  final ListeningLabService listening;
  final GamificationService gamification;
  final StudentProfileService profile;
  final LearningFeedbackService teacher;

  @override
  State<ListeningLabScreen> createState() =>
      _ListeningLabScreenState();
}

class _ListeningLabScreenState extends State<ListeningLabScreen> {
  final speech = SpeechToText();
  final transcriptController = TextEditingController();

  List<ListeningExercise> exercises = const [];
  int index = 0;
  bool loading = true;
  bool listeningNow = false;
  bool solved = false;
  double? dictationScore;

  ListeningExercise get exercise => exercises[index];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.profile.load();
    await widget.gamification.load();
    final data = await widget.content.loadListening(
      widget.profile.profile.level,
    );
    if (!mounted) return;
    setState(() {
      exercises = data;
      loading = false;
    });
    await _play();
  }

  Future<void> _play() async {
    if (exercises.isEmpty) return;
    await widget.teacher.act(
      state: LearningFeedbackState.reading,
      message: exercise.english,
      prop: LearningFeedbackContext.book,
    );
  }

  Future<void> _choose(int answer) async {
    if (solved) return;
    final correct = widget.listening.checkChoice(exercise, answer);
    await widget.listening.save(
      exercise: exercise,
      correct: correct,
      transcript: exercise.options[answer],
      score: correct ? 1 : 0,
    );

    if (correct) {
      await _reward();
    } else {
      await widget.teacher.correct(
        'আবার মন দিয়ে শোনো।',
      );
    }
  }

  Future<void> _startDictation() async {
    final available = await speech.initialize();
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech recognition এই device-এ পাওয়া যায়নি। '
            'নিচের box-এ শুনে লিখতে পারো।',
          ),
        ),
      );
      return;
    }

    setState(() => listeningNow = true);
    await widget.teacher.listen();
    await speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: 'en_US',
      ),
      onResult: (result) {
        transcriptController.text = result.recognizedWords;
        if (result.finalResult) {
          _checkDictation();
        }
      },
    );
  }

  Future<void> _checkDictation() async {
    await speech.stop();
    final text = transcriptController.text.trim();
    final score = widget.listening.scoreDictation(
      exercise,
      text,
    );
    final correct = score >= .72;

    await widget.listening.save(
      exercise: exercise,
      correct: correct,
      transcript: text,
      score: score,
    );

    if (!mounted) return;
    setState(() {
      listeningNow = false;
      dictationScore = score;
    });

    if (correct) {
      await _reward();
    } else {
      await widget.teacher.correct(
        'আরও একবার শুনে লিখো। '
        'তোমার score ${(score * 100).round()} percent.',
      );
    }
  }

  Future<void> _reward() async {
    final awarded = await widget.gamification.award(
      sourceType: 'listening',
      sourceId: exercise.id,
      xp: exercise.xp,
      coins: exercise.coins,
    );
    if (!mounted) return;
    setState(() => solved = true);
    await widget.teacher.praise(
      awarded
          ? 'Listening complete! ${exercise.xp} XP এবং '
              '${exercise.coins} coins পেয়েছ।'
          : 'সঠিক! এই exercise-এর reward আগে পাওয়া হয়েছে।',
    );
  }

  Future<void> _next() async {
    setState(() {
      index = (index + 1) % exercises.length;
      listeningNow = false;
      solved = false;
      dictationScore = null;
      transcriptController.clear();
    });
    await _play();
  }

  @override
  void dispose() {
    speech.stop();
    transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (exercises.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No listening exercises.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Listening Lab')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LearningFeedbackAnchor(teacher: widget.teacher, height: 255),
          const SizedBox(height: 14),
          Card(
            color: const Color(0xFFFFF1C7),
            child: Padding(
              padding: const EdgeInsets.all(19),
              child: Column(
                children: [
                  const Icon(
                    Icons.headphones_rounded,
                    size: 52,
                    color: MewtionaryTheme.teal,
                  ),
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      fontSize: 22,
                      color: MewtionaryTheme.navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Exercise ${index + 1}/${exercises.length} · '
                    '+${exercise.xp} XP',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _play,
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Listen Again'),
                  ),
                ],
              ),
            ),
          ),
          if (exercise.mode == 'mcq')
            for (var i = 0; i < exercise.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: OutlinedButton(
                  onPressed: solved ? null : () => _choose(i),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      exercise.options[i],
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'শুনে sentence-টি বলো অথবা লিখো',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: transcriptController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type what you heard…',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: solved || listeningNow
                                ? null
                                : _startDictation,
                            icon: Icon(
                              listeningNow
                                  ? Icons.hearing_rounded
                                  : Icons.mic_rounded,
                            ),
                            label: Text(
                              listeningNow ? 'Listening…' : 'Speak',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: solved ? null : _checkDictation,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Check'),
                          ),
                        ),
                      ],
                    ),
                    if (dictationScore != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Transcript score: '
                          '${(dictationScore! * 100).round()}%',
                          style: const TextStyle(
                            color: MewtionaryTheme.teal,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (solved)
            FilledButton.icon(
              onPressed: _next,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next Exercise'),
            ),
        ],
      ),
    );
  }
}
