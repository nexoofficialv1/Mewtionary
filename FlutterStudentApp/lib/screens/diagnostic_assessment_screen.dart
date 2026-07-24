import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../models/adaptive_learning_models.dart';
import '../services/diagnostic_service.dart';
import '../services/student_profile_service.dart';
import '../services/teacher_orchestrator.dart';
import '../widgets/teacher_viewport.dart';

class DiagnosticAssessmentScreen extends StatefulWidget {
  const DiagnosticAssessmentScreen({
    required this.service,
    required this.profile,
    required this.teacher,
    super.key,
  });

  final DiagnosticService service;
  final StudentProfileService profile;
  final TeacherOrchestrator teacher;

  @override
  State<DiagnosticAssessmentScreen> createState() =>
      _DiagnosticAssessmentScreenState();
}

class _DiagnosticAssessmentScreenState
    extends State<DiagnosticAssessmentScreen> {
  List<DiagnosticQuestion> questions = const [];
  final answers = <String, int>{};
  int index = 0;
  bool loading = true;
  DiagnosticResult? result;

  DiagnosticQuestion get current => questions[index];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await widget.service.loadQuestions();
    if (!mounted) return;
    setState(() {
      questions = loaded;
      loading = false;
    });
    await widget.teacher.act(
      state: widget.teacher.status.state,
      message:
          'আমি কয়েকটি সহজ প্রশ্ন করব। ভয় নেই—এটি পরীক্ষা নয়, সঠিক level খুঁজে নেওয়ার উপায়।',
    );
  }

  Future<void> _answer(int option) async {
    answers[current.id] = option;
    final correct = option == current.correctIndex;
    if (correct) {
      await widget.teacher.praise('ভালো! পরের প্রশ্নে যাই।');
    } else {
      await widget.teacher.correct(current.hint);
    }

    if (index < questions.length - 1) {
      setState(() => index++);
      return;
    }

    final next = widget.service.evaluate(
      questions: questions,
      answers: answers,
    );
    await widget.service.save(next);
    if (!mounted) return;
    setState(() => result = next);
  }

  Future<void> _apply() async {
    final value = result;
    if (value == null) return;
    await widget.profile.applyDiagnosticLevel(
      value.recommendedLevel,
    );
    await widget.teacher.praise(
      'তোমার learning level ${value.recommendedLevel.title} হিসেবে save হয়েছে।',
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Placement Assessment')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TeacherViewport(teacher: widget.teacher, height: 255),
                const SizedBox(height: 14),
                if (result == null) ...[
                  LinearProgressIndicator(
                    value: (index + 1) / questions.length,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Question ${index + 1} of ${questions.length}',
                    style: const TextStyle(
                      color: MewtionaryTheme.teal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(19),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            current.question,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          for (var i = 0;
                              i < current.options.length;
                              i++)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 9),
                              child: OutlinedButton(
                                onPressed: () => _answer(i),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(12),
                                  child: Text(
                                    current.options[i],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ] else
                  Card(
                    color: const Color(0xFFFFF1C7),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            size: 64,
                            color: MewtionaryTheme.amber,
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
                            'Recommended: '
                            '${result!.recommendedLevel.title}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            result!.recommendedLevel.banglaTitle,
                            style: const TextStyle(
                              color: MewtionaryTheme.teal,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _apply,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text(
                              'Use Recommended Level',
                            ),
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
