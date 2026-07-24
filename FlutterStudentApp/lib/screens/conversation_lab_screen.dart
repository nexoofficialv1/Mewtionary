import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/mewtionary_theme.dart';
import '../models/tutor_studio_models.dart';
import '../services/conversation_tutor_service.dart';
import '../services/gamification_service.dart';
import '../services/student_profile_service.dart';
import '../services/learning_feedback_service.dart';
import '../services/tutor_studio_content_service.dart';
import '../widgets/learning_feedback_anchor.dart';

class ConversationLabScreen extends StatefulWidget {
  const ConversationLabScreen({
    required this.content,
    required this.tutor,
    required this.gamification,
    required this.profile,
    required this.teacher,
    super.key,
  });

  final TutorStudioContentService content;
  final ConversationTutorService tutor;
  final GamificationService gamification;
  final StudentProfileService profile;
  final LearningFeedbackService teacher;

  @override
  State<ConversationLabScreen> createState() =>
      _ConversationLabScreenState();
}

class _ConversationLabScreenState
    extends State<ConversationLabScreen> {
  List<ConversationScenario> scenarios = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.profile.load();
    await widget.gamification.load();
    final data = await widget.content.loadConversations(
      widget.profile.profile.level,
    );
    if (!mounted) return;
    setState(() {
      scenarios = data;
      loading = false;
    });
  }

  Future<void> _open(ConversationScenario scenario) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ConversationPlayerScreen(
          scenario: scenario,
          tutor: widget.tutor,
          gamification: widget.gamification,
          teacher: widget.teacher,
        ),
      ),
    );
    await widget.gamification.load();
    if (mounted) setState(() {});
  }

  IconData _locationIcon(String location) {
    final value = location.toLowerCase();
    if (value.contains('shop')) return Icons.storefront_rounded;
    if (value.contains('clinic')) return Icons.local_hospital_rounded;
    if (value.contains('interview')) return Icons.badge_rounded;
    return Icons.school_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversation Lab')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                LearningFeedbackAnchor(
                  teacher: widget.teacher,
                  height: 260,
                ),
                const SizedBox(height: 14),
                const Card(
                  color: Color(0xFFFFF1C7),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: MewtionaryTheme.amber,
                      child: Icon(
                        Icons.forum_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Real-life English Practice',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      'Voice অথবা typing দিয়ে guided conversation complete করো',
                    ),
                  ),
                ),
                for (final scenario in scenarios)
                  Card(
                    child: ListTile(
                      onTap: () => _open(scenario),
                      leading: CircleAvatar(
                        backgroundColor:
                            MewtionaryTheme.teal.withValues(alpha: .12),
                        child: Icon(
                          _locationIcon(scenario.location),
                          color: MewtionaryTheme.teal,
                        ),
                      ),
                      title: Text(
                        scenario.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        '${scenario.banglaTitle}\n${scenario.intro}',
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        '+${scenario.xp} XP',
                        style: const TextStyle(
                          color: MewtionaryTheme.teal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Conversation Lab একটি offline guided dialogue engine। '
                      'এটি open-ended internet AI chat নয়; approved scenario, '
                      'keyword feedback এবং child-safe prompts ব্যবহার করে।',
                      style: TextStyle(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class ConversationPlayerScreen extends StatefulWidget {
  const ConversationPlayerScreen({
    required this.scenario,
    required this.tutor,
    required this.gamification,
    required this.teacher,
    super.key,
  });

  final ConversationScenario scenario;
  final ConversationTutorService tutor;
  final GamificationService gamification;
  final LearningFeedbackService teacher;

  @override
  State<ConversationPlayerScreen> createState() =>
      _ConversationPlayerScreenState();
}

class _ConversationPlayerScreenState
    extends State<ConversationPlayerScreen> {
  final answerController = TextEditingController();
  final speech = SpeechToText();
  final transcript = <Map<String, dynamic>>[];

  late ConversationNode node;
  bool listening = false;
  bool completed = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    node = widget.scenario.nodeById(
      widget.scenario.startNodeId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  Future<void> _speakPrompt() {
    return widget.teacher.act(
      state: LearningFeedbackState.speaking,
      message: node.prompt,
      prop: LearningFeedbackContext.none,
    );
  }

  Future<void> _startListening() async {
    final available = await speech.initialize();
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech recognition পাওয়া যায়নি। উত্তরটি type করো।',
          ),
        ),
      );
      return;
    }

    setState(() => listening = true);
    await widget.teacher.listen();
    await speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: 'en_US',
      ),
      onResult: (result) {
        answerController.text = result.recognizedWords;
        if (result.finalResult) {
          setState(() => listening = false);
          _submit();
        }
      },
    );
  }

  Future<void> _submit() async {
    if (completed) return;
    await speech.stop();
    final answer = answerController.text.trim();
    if (answer.isEmpty) return;

    final evaluation = widget.tutor.evaluate(
      node: node,
      answer: answer,
    );

    transcript.add({
      'speaker': node.speaker,
      'prompt': node.prompt,
      'student': answer,
      'accepted': evaluation.accepted,
      'score': evaluation.score,
    });

    if (!evaluation.accepted) {
      final missing = evaluation.missingKeywords.isEmpty
          ? node.teacherHint
          : 'এই শব্দগুলো ব্যবহার করার চেষ্টা করো: '
              '${evaluation.missingKeywords.join(', ')}.';
      await widget.teacher.correct(missing);
      if (!mounted) return;
      setState(() => listening = false);
      return;
    }

    score += evaluation.score;
    await widget.teacher.praise(
      evaluation.reply.teacherReply.isEmpty
          ? 'ভালো বলেছ!'
          : evaluation.reply.teacherReply,
    );

    final nextId = evaluation.reply.nextNodeId;
    if (node.isFinal || nextId == null) {
      await _finish();
      return;
    }

    if (!mounted) return;
    setState(() {
      node = widget.scenario.nodeById(nextId);
      answerController.clear();
      listening = false;
    });
    await _speakPrompt();
  }

  Future<void> _finish() async {
    await widget.tutor.saveAttempt(
      scenario: widget.scenario,
      score: score,
      transcript: transcript,
    );
    final date = DateTime.now();
    final rewardId =
        '${widget.scenario.id}_${date.year}_${date.month}_${date.day}';
    final awarded = await widget.gamification.award(
      sourceType: 'conversation',
      sourceId: rewardId,
      xp: widget.scenario.xp,
      coins: widget.scenario.coins,
    );
    if (!mounted) return;
    setState(() {
      completed = true;
      listening = false;
    });
    await widget.teacher.praise(
      awarded
          ? 'Conversation complete! ${widget.scenario.xp} XP এবং '
              '${widget.scenario.coins} coins পেয়েছ।'
          : 'Conversation complete! আজকের reward আগে পাওয়া হয়েছে।',
    );
  }

  @override
  void dispose() {
    speech.stop();
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelAnswer =
        node.replies.isEmpty ? '' : node.replies.first.text;

    return Scaffold(
      appBar: AppBar(title: Text(widget.scenario.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LearningFeedbackAnchor(
            teacher: widget.teacher,
            height: 250,
          ),
          const SizedBox(height: 14),
          if (!completed) ...[
            Card(
              color: const Color(0xFFFFF1C7),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      node.speaker,
                      style: const TextStyle(
                        color: MewtionaryTheme.teal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      node.prompt,
                      style: const TextStyle(
                        fontSize: 21,
                        height: 1.35,
                        color: MewtionaryTheme.navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(node.banglaPrompt),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _speakPrompt,
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('Listen Again'),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: answerController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Your answer',
                        hintText: 'Speak or type in English…',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                listening ? null : _startListening,
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
                            onPressed: _submit,
                            icon: const Icon(Icons.send_rounded),
                            label: const Text('Reply'),
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text(
                        'Hint',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(node.teacherHint),
                        ),
                        if (modelAnswer.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 10,
                              ),
                              child: Text(
                                'Model: $modelAnswer',
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Card(
              color: const Color(0xFFDFF4E2),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.record_voice_over_rounded,
                      size: 62,
                      color: Colors.green,
                    ),
                    const Text(
                      'Conversation Complete',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text('Dialogue score: $score'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Scenarios'),
                    ),
                  ],
                ),
              ),
            ),
          if (transcript.isNotEmpty)
            Card(
              child: ExpansionTile(
                title: const Text(
                  'Conversation Transcript',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                children: [
                  for (final line in transcript)
                    ListTile(
                      title: Text(line['prompt'] as String),
                      subtitle: Text(
                        'You: ${line['student']}',
                      ),
                      trailing: Icon(
                        line['accepted'] as bool
                            ? Icons.check_circle_rounded
                            : Icons.info_rounded,
                        color: line['accepted'] as bool
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
