import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../curriculum/curriculum_engine.dart';
import '../models/curriculum_models.dart';
import '../services/adaptive_learning_dialogue.dart';
import '../services/learning_feedback_service.dart';
import '../widgets/learning_feedback_anchor.dart';

class LessonPlayerScreen extends StatefulWidget {
  const LessonPlayerScreen({
    required this.lesson,
    required this.teacher,
    required this.engine,
    super.key,
  });

  final CurriculumLesson lesson;
  final LearningFeedbackService teacher;
  final CurriculumEngine engine;

  @override
  State<LessonPlayerScreen> createState() =>
      _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  int? selected;
  bool answered = false;

  Map<String, dynamic> get activity =>
      widget.lesson.activities.isEmpty
          ? <String, dynamic>{}
          : widget.lesson.activities.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _explain());
  }

  Future<void> _explain() async {
    await widget.teacher.act(
      state: _teacherState(widget.lesson.teacherState),
      message: widget.lesson.explanation,
      prop: widget.lesson.skill == CurriculumSkill.story
          ? LearningFeedbackContext.book
          : widget.lesson.skill == CurriculumSkill.grammar
              ? LearningFeedbackContext.pointer
              : LearningFeedbackContext.none,
    );
  }

  Future<void> _answer(int index) async {
    if (answered) return;
    final correct = index == (activity['correctIndex'] as int? ?? 0);
    final score = correct ? 1.0 : .35;

    setState(() {
      selected = index;
      answered = true;
    });

    await AdaptiveLearningDialogue(widget.teacher).react(
      score: score,
      attempts: widget.engine.progressFor(widget.lesson.id).attempts,
      hint: activity['hint'] as String?,
    );
  }

  Future<void> _complete() async {
    final correct =
        selected == (activity['correctIndex'] as int? ?? 0);
    final score = activity.isEmpty ? 1.0 : (correct ? 1.0 : .35);
    await widget.engine.completeLesson(
      widget.lesson,
      score: score,
    );
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lesson Complete'),
        content: Text(
          'Mastery: ${(score * 100).round()}%\n'
          'Stars: ${widget.lesson.stars}',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Learning Path'),
          ),
        ],
      ),
    );
  }

  LearningFeedbackState _teacherState(String value) {
    return LearningFeedbackState.values.firstWhere(
      (item) => item.name.toLowerCase() == value.toLowerCase(),
      orElse: () => LearningFeedbackState.speaking,
    );
  }

  @override
  Widget build(BuildContext context) {
    final options =
        (activity['options'] as List<dynamic>? ?? const []).cast<String>();
    final correctIndex = activity['correctIndex'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LearningFeedbackAnchor(teacher: widget.teacher, height: 275),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.lesson.banglaTitle,
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: MewtionaryTheme.navy,
                              fontWeight: FontWeight.w900,
                            ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lesson.explanation,
                    style: const TextStyle(
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _explain,
                    icon: const Icon(Icons.school_rounded),
                    label: const Text('আবার বুঝিয়ে দাও'),
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: const Color(0xFFFFF6DD),
            child: Padding(
              padding: const EdgeInsets.all(19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    activity['question'] as String? ??
                        'Lesson complete করতে নিচের button চাপুন।',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < options.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: answered && i == correctIndex
                            ? Colors.green.shade100
                            : answered &&
                                    selected == i &&
                                    i != correctIndex
                                ? Colors.red.shade100
                                : selected == i
                                    ? MewtionaryTheme.teal.withValues(alpha: .12)
                                    : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => _answer(i),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Icon(
                                  answered && i == correctIndex
                                      ? Icons.check_circle_rounded
                                      : answered &&
                                              selected == i &&
                                              i != correctIndex
                                          ? Icons.cancel_rounded
                                          : selected == i
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_off,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    options[i],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (activity.isEmpty || answered)
                    FilledButton(
                      onPressed: _complete,
                      child: const Text('Complete Lesson'),
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
