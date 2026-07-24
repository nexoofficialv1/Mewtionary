import 'package:flutter/material.dart';
import 'package:mewtionary_teacher3d_bridge/mewtionary_teacher3d_bridge.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/mewtionary_theme.dart';
import '../models/exam_coach_models.dart';
import '../services/exam_coach_content_service.dart';
import '../services/gamification_service.dart';
import '../services/pronunciation_coach_service.dart';
import '../services/student_profile_service.dart';
import '../services/teacher_orchestrator.dart';
import '../widgets/teacher_viewport.dart';

class PronunciationCoachScreen extends StatefulWidget {
  const PronunciationCoachScreen({
    required this.content,
    required this.coach,
    required this.gamification,
    required this.profile,
    required this.teacher,
    super.key,
  });

  final ExamCoachContentService content;
  final PronunciationCoachService coach;
  final GamificationService gamification;
  final StudentProfileService profile;
  final TeacherOrchestrator teacher;

  @override
  State<PronunciationCoachScreen> createState() =>
      _PronunciationCoachScreenState();
}

class _PronunciationCoachScreenState
    extends State<PronunciationCoachScreen> {
  final speech = SpeechToText();
  final transcriptController = TextEditingController();

  List<PronunciationExercise> exercises = const [];
  int index = 0;
  bool loading = true;
  bool listening = false;
  bool speechReady = false;
  PronunciationCoachResult? result;

  PronunciationExercise get exercise => exercises[index];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.profile.load();
    await widget.gamification.load();
    speechReady = await speech.initialize();
    final data = await widget.content.loadPronunciation(
      widget.profile.profile.level,
    );
    if (!mounted) return;
    setState(() {
      exercises = data;
      loading = false;
    });
    await _teacherModel();
  }

  Future<void> _teacherModel() async {
    if (exercises.isEmpty) return;
    await widget.teacher.act(
      state: Teacher3DState.speaking,
      message: 'Repeat after me: ${exercise.target}',
    );
  }

  Future<void> _start() async {
    if (!speechReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech recognition পাওয়া যায়নি। Transcript box-এ লিখে Check করো।',
          ),
        ),
      );
      return;
    }

    setState(() {
      listening = true;
      result = null;
      transcriptController.clear();
    });
    await widget.teacher.listen();
    await speech.listen(
      localeId: 'en_US',
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
      onResult: (value) {
        transcriptController.text = value.recognizedWords;
        if (value.finalResult) {
          _check();
        }
      },
    );
  }

  Future<void> _check() async {
    await speech.stop();
    final transcript = transcriptController.text.trim();
    if (transcript.isEmpty) return;

    final value = await widget.coach.evaluate(
      exercise: exercise,
      transcript: transcript,
    );
    if (!mounted) return;
    setState(() {
      result = value;
      listening = false;
    });

    if (value.successful) {
      final rewarded = await widget.gamification.award(
        sourceType: 'pronunciation',
        sourceId: exercise.id,
        xp: exercise.xp,
        coins: exercise.coins,
      );
      await widget.teacher.praise(
        rewarded
            ? 'Clear speech! ${exercise.xp} XP এবং '
                '${exercise.coins} coins পেয়েছ।'
            : 'উচ্চারণটি ভালো হয়েছে। এই lesson-এর reward আগে পাওয়া হয়েছে।',
      );
    } else {
      await widget.teacher.correct(
        '${exercise.mouthTip} ${value.feedback.first}',
      );
    }
  }

  Future<void> _next() async {
    setState(() {
      index = (index + 1) % exercises.length;
      result = null;
      listening = false;
      transcriptController.clear();
    });
    await _teacherModel();
  }

  @override
  void dispose() {
    speech.cancel();
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
        body: Center(child: Text('No pronunciation lessons.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pronunciation Coach')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TeacherViewport(
            teacher: widget.teacher,
            height: 255,
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: (index + 1) / exercises.length,
            minHeight: 9,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 10),
          Card(
            color: const Color(0xFFFFF1C7),
            child: Padding(
              padding: const EdgeInsets.all(19),
              child: Column(
                children: [
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      color: MewtionaryTheme.teal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    exercise.target,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.35,
                      color: MewtionaryTheme.navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    exercise.bangla,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final chunk in exercise.syllables)
                        Chip(label: Text(chunk)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _teacherModel,
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Teacher Model'),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Sound Focus',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(exercise.focusSounds.join('  ·  ')),
                  const SizedBox(height: 7),
                  Text(
                    exercise.mouthTip,
                    style: const TextStyle(height: 1.4),
                  ),
                  if (exercise.minimalPairs.isNotEmpty) ...[
                    const Divider(height: 22),
                    const Text(
                      'Minimal Pairs',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(exercise.minimalPairs.join('   |   ')),
                  ],
                ],
              ),
            ),
          ),
          TextField(
            controller: transcriptController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Your transcript',
              hintText: 'Speak or type the target sentence…',
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: listening ? null : _start,
                  icon: Icon(
                    listening
                        ? Icons.hearing_rounded
                        : Icons.mic_rounded,
                  ),
                  label: Text(
                    listening ? 'Listening…' : 'Speak',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _check,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Check'),
                ),
              ),
            ],
          ),
          if (result != null)
            Card(
              color: result!.successful
                  ? const Color(0xFFDFF4E2)
                  : const Color(0xFFFFE7D8),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pronunciation Score: '
                      '${(result!.score.total * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: result!.score.total,
                      minHeight: 11,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Word coverage: '
                      '${(result!.score.wordCoverage * 100).round()}%',
                    ),
                    Text(
                      'Sequence accuracy: '
                      '${(result!.score.sequenceAccuracy * 100).round()}%',
                    ),
                    for (final message in result!.feedback)
                      Text('• $message'),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: _next,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Next Pronunciation'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
