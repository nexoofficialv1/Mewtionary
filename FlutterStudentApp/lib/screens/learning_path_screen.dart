import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../curriculum/curriculum_engine.dart';
import '../curriculum/curriculum_repository.dart';
import '../models/curriculum_models.dart';
import '../services/adaptive_learning_dialogue.dart';
import '../services/learning_feedback_service.dart';
import '../widgets/learning_feedback_anchor.dart';
import 'lesson_player_screen.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({
    required this.teacher,
    required this.engine,
    required this.repository,
    super.key,
  });

  final LearningFeedbackService teacher;
  final CurriculumEngine engine;
  final CurriculumRepository repository;

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  CurriculumLevel level = CurriculumLevel.class4;
  List<CurriculumUnit> units = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await widget.repository.loadLevel(level);
    await widget.engine.load();
    if (!mounted) return;
    setState(() {
      units = data;
      loading = false;
    });
  }

  Future<void> _open(CurriculumLesson lesson) async {
    if (!widget.engine.isUnlocked(lesson)) return;
    await widget.engine.markOpened(lesson);
    await AdaptiveLearningDialogue(widget.teacher).introduce(lesson);
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => LessonPlayerScreen(
          lesson: lesson,
          teacher: widget.teacher,
          engine: widget.engine,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final reviewCount =
        loading ? 0 : widget.engine.reviewQueue(units).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Class-wise Learning Path')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LearningFeedbackAnchor(teacher: widget.teacher, height: 275),
          const SizedBox(height: 14),
          DropdownButtonFormField<CurriculumLevel>(
            value: level,
            decoration: const InputDecoration(
              labelText: 'Learning level',
              prefixIcon: Icon(Icons.school_rounded),
            ),
            items: CurriculumLevel.values
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      '${item.title} — ${item.banglaTitle}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              level = value;
              _load();
            },
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFFFFF1C7),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: MewtionaryTheme.amber,
                child: Icon(Icons.replay_rounded, color: Colors.white),
              ),
              title: Text(
                reviewCount == 0
                    ? 'আজ revision বাকি নেই'
                    : 'আজ $reviewCountটি revision আছে',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                'Spaced revision শেখা মনে রাখতে সাহায্য করবে।',
              ),
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            ),
          for (final unit in units)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      unit.title,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: MewtionaryTheme.navy,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    Text(
                      unit.banglaTitle,
                      style: const TextStyle(
                        color: MewtionaryTheme.teal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit.description,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    for (final lesson in unit.lessons)
                      _LessonTile(
                        lesson: lesson,
                        record: widget.engine.progressFor(lesson.id),
                        unlocked: widget.engine.isUnlocked(lesson),
                        onTap: () => _open(lesson),
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

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.record,
    required this.unlocked,
    required this.onTap,
  });

  final CurriculumLesson lesson;
  final LessonProgressRecord record;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: unlocked,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: record.completed
            ? Colors.green.shade100
            : unlocked
                ? MewtionaryTheme.teal.withOpacity(.12)
                : Colors.grey.shade200,
        child: Icon(
          record.completed
              ? Icons.check_rounded
              : unlocked
                  ? Icons.play_arrow_rounded
                  : Icons.lock_rounded,
          color: record.completed
              ? Colors.green
              : unlocked
                  ? MewtionaryTheme.teal
                  : Colors.grey,
        ),
      ),
      title: Text(
        lesson.title,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        '${lesson.banglaTitle} · '
        '${lesson.skill.label} · '
        '${lesson.estimatedMinutes} min',
      ),
      trailing: record.completed
          ? Text(
              '${(record.mastery * 100).round()}%',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w900,
              ),
            )
          : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
    );
  }
}
