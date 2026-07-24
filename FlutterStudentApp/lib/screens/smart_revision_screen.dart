import 'package:flutter/material.dart';
import 'package:mewtionary_teacher3d_bridge/mewtionary_teacher3d_bridge.dart';

import '../core/mewtionary_theme.dart';
import '../models/curriculum_models.dart';
import '../models/tutor_studio_models.dart';
import '../services/gamification_service.dart';
import '../services/learning_analytics_service.dart';
import '../services/smart_revision_service.dart';
import '../services/student_profile_service.dart';
import '../services/teacher_orchestrator.dart';
import '../services/tutor_studio_content_service.dart';
import '../widgets/teacher_viewport.dart';

class SmartRevisionScreen extends StatefulWidget {
  const SmartRevisionScreen({
    required this.content,
    required this.revision,
    required this.analytics,
    required this.gamification,
    required this.profile,
    required this.teacher,
    super.key,
  });

  final TutorStudioContentService content;
  final SmartRevisionService revision;
  final LearningAnalyticsService analytics;
  final GamificationService gamification;
  final StudentProfileService profile;
  final TeacherOrchestrator teacher;

  @override
  State<SmartRevisionScreen> createState() =>
      _SmartRevisionScreenState();
}

class _SmartRevisionScreenState
    extends State<SmartRevisionScreen> {
  List<RevisionQuestion> questions = const [];
  final answers = <String, int>{};
  int index = 0;
  bool loading = true;
  bool answered = false;
  RevisionResult? result;

  RevisionQuestion get question => questions[index];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.profile.load();
    await widget.gamification.load();
    final all = await widget.content.loadRevisionQuestions();
    final analytics = await widget.analytics.load();
    final weakSkills = [...analytics.skills]
      ..sort((a, b) => a.mastery.compareTo(b.mastery));

    final quiz = widget.revision.buildQuiz(
      all: all,
      level: widget.profile.profile.level,
      weakSkills: weakSkills.map((item) => item.skill).toList(),
    );

    if (!mounted) return;
    setState(() {
      questions = quiz;
      loading = false;
    });
    await widget.teacher.act(
      state: Teacher3DState.pointing,
      message:
          '${widget.profile.profile.name}, দুর্বল skill আগে রেখে আজকের revision তৈরি হয়েছে।',
      prop: Teacher3DProp.pointer,
    );
  }

  Future<void> _answer(int option) async {
    if (answered || result != null) return;
    answers[question.id] = option;
    final correct = option == question.correctIndex;

    if (correct) {
      await widget.teacher.praise('সঠিক উত্তর!');
    } else {
      await widget.teacher.correct(question.explanation);
    }

    if (!mounted) return;
    setState(() => answered = true);
  }

  Future<void> _next() async {
    if (index < questions.length - 1) {
      setState(() {
        index++;
        answered = false;
      });
      return;
    }

    final value = widget.revision.evaluate(
      questions: questions,
      answers: answers,
    );
    await widget.revision.save(
      level: widget.profile.profile.level,
      result: value,
    );

    final today = DateTime.now();
    final rewardId = '${widget.profile.profile.level.id}_'
        '${today.year}_${today.month}_${today.day}';
    final xp = 10 + value.correct * 3;
    final coins = value.score >= .75 ? 5 : 2;
    await widget.gamification.award(
      sourceType: 'revision',
      sourceId: rewardId,
      xp: xp,
      coins: coins,
    );

    if (!mounted) return;
    setState(() => result = value);
    await widget.teacher.praise(
      'Revision complete! Score ${(value.score * 100).round()} percent.',
    );
  }

  Future<void> _restart() async {
    setState(() {
      index = 0;
      answered = false;
      answers.clear();
      result = null;
      loading = true;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No revision questions available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Revision')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TeacherViewport(
            teacher: widget.teacher,
            height: 245,
          ),
          const SizedBox(height: 14),
          if (result == null) ...[
            LinearProgressIndicator(
              value: (index + 1) / questions.length,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 9),
            Card(
              color: const Color(0xFFFFF1C7),
              child: Padding(
                padding: const EdgeInsets.all(19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${question.skill.label} · '
                      'Question ${index + 1}/${questions.length}',
                      style: const TextStyle(
                        color: MewtionaryTheme.teal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      question.prompt,
                      style: const TextStyle(
                        fontSize: 21,
                        height: 1.35,
                        color: MewtionaryTheme.navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < question.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: OutlinedButton(
                  onPressed: answered ? null : () => _answer(i),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Text(
                      question.options[i],
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            if (answered)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    question.explanation,
                    style: const TextStyle(height: 1.4),
                  ),
                ),
              ),
            if (answered)
              FilledButton.icon(
                onPressed: _next,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  index == questions.length - 1
                      ? 'Finish Revision'
                      : 'Next Question',
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
                      Icons.psychology_alt_rounded,
                      size: 65,
                      color: Colors.green,
                    ),
                    Text(
                      '${(result!.score * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 42,
                        color: MewtionaryTheme.navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${result!.correct}/${result!.total} correct',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final entry
                        in result!.skillScores.entries)
                      ListTile(
                        dense: true,
                        title: Text(entry.key.label),
                        trailing: Text(
                          '${(entry.value * 100).round()}%',
                          style: const TextStyle(
                            color: MewtionaryTheme.teal,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: _restart,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Build Another Revision'),
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
