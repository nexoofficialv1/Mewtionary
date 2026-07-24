import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../data/content_repository.dart';
import '../models/learning_models.dart';
import '../services/progress_service.dart';
import '../services/learning_feedback_service.dart';
import '../widgets/learning_feedback_anchor.dart';

class TenseScreen extends StatefulWidget {
  const TenseScreen({
    required this.teacher,
    required this.progress,
    required this.repository,
    super.key,
  });

  final LearningFeedbackService teacher;
  final ProgressService progress;
  final ContentRepository repository;

  @override
  State<TenseScreen> createState() => _TenseScreenState();
}

class _TenseScreenState extends State<TenseScreen> {
  List<TenseLesson> lessons = const [];
  int lessonIndex = 0;
  int quizIndex = 0;
  int? selectedAnswer;
  bool answered = false;

  TenseLesson get lesson => lessons[lessonIndex];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.repository.loadTenses();
    if (!mounted) return;
    setState(() => lessons = data);
    await _teachRule();
  }

  Future<void> _teachRule() async {
    if (lessons.isEmpty) return;
    await widget.teacher.act(
      state: LearningFeedbackState.writingBoard,
      message: '${lesson.title}. ${lesson.rule}',
      prop: LearningFeedbackContext.chalk,
    );
  }

  Future<void> _answer(int index) async {
    if (answered) return;
    final question = lesson.quiz[quizIndex];
    final correct = index == question.correctIndex;
    setState(() {
      selectedAnswer = index;
      answered = true;
    });

    if (correct) {
      await widget.teacher.praise();
    } else {
      await widget.teacher.correct(question.hint);
    }
  }

  Future<void> _nextQuestion() async {
    final lastQuestion = quizIndex == lesson.quiz.length - 1;
    if (lastQuestion) {
      await widget.progress.completeGrammar();
      await widget.teacher.act(
        state: LearningFeedbackState.dancing,
        message: 'অসাধারণ! এই grammar lesson complete হয়েছে।',
        duration: 2.8,
      );
      if (!mounted) return;
      setState(() {
        quizIndex = 0;
        selectedAnswer = null;
        answered = false;
      });
      return;
    }

    setState(() {
      quizIndex++;
      selectedAnswer = null;
      answered = false;
    });
    await widget.teacher.act(
      state: LearningFeedbackState.thinking,
      message: lesson.quiz[quizIndex].question,
      speak: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = lesson.quiz[quizIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Tense & Grammar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LearningFeedbackAnchor(
            teacher: widget.teacher,
            height: 285,
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: MewtionaryTheme.navy,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    lesson.banglaTitle,
                    style: const TextStyle(
                      color: MewtionaryTheme.teal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    lesson.rule,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...lesson.examples.map(
                    (example) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: MewtionaryTheme.teal,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(example)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _teachRule,
                    icon: const Icon(Icons.cast_for_education_rounded),
                    label: const Text('আবার বুঝিয়ে দাও'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            color: const Color(0xFFFFF5D8),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Quiz ${quizIndex + 1}/${lesson.quiz.length}',
                    style: const TextStyle(
                      color: MewtionaryTheme.teal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (var i = 0; i < question.options.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _QuizOption(
                        label: question.options[i],
                        selected: selectedAnswer == i,
                        correct: answered &&
                            i == question.correctIndex,
                        wrong: answered &&
                            selectedAnswer == i &&
                            i != question.correctIndex,
                        onTap: () => _answer(i),
                      ),
                    ),
                  if (answered)
                    FilledButton(
                      onPressed: _nextQuestion,
                      child: Text(
                        quizIndex == lesson.quiz.length - 1
                            ? 'Complete Lesson'
                            : 'Next Question',
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

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.label,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (correct) color = Colors.green.shade100;
    if (wrong) color = Colors.red.shade100;
    if (selected && !correct && !wrong) {
      color = MewtionaryTheme.teal.withValues(alpha: .12);
    }

    return Material(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : wrong
                        ? Icons.cancel_rounded
                        : selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                color: correct
                    ? Colors.green
                    : wrong
                        ? Colors.red
                        : MewtionaryTheme.teal,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
