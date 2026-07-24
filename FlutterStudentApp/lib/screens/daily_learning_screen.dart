import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../models/adaptive_learning_models.dart';
import '../services/daily_plan_service.dart';
import '../services/student_profile_service.dart';
import '../services/teacher_orchestrator.dart';
import '../widgets/teacher_viewport.dart';

class DailyLearningScreen extends StatefulWidget {
  const DailyLearningScreen({
    required this.service,
    required this.profile,
    required this.teacher,
    super.key,
  });

  final DailyPlanService service;
  final StudentProfileService profile;
  final TeacherOrchestrator teacher;

  @override
  State<DailyLearningScreen> createState() =>
      _DailyLearningScreenState();
}

class _DailyLearningScreenState extends State<DailyLearningScreen> {
  List<DailyPlanItem> items = const [];
  Set<String> completed = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.profile.load();
    final plan = await widget.service.build(
      widget.profile.profile.level,
    );
    final done = await widget.service.completedToday();
    if (!mounted) return;
    setState(() {
      items = plan;
      completed = done;
      loading = false;
    });
    await widget.teacher.act(
      state: widget.teacher.status.state,
      message:
          '${widget.profile.profile.name}, আজ তোমার ${items.length}টি ছোট learning task আছে।',
    );
  }

  Future<void> _open(DailyPlanItem item) async {
    await Navigator.pushNamed(context, item.route);
    await widget.service.markComplete(item.id);
    if (!mounted) return;
    setState(() => completed.add(item.id));

    if (completed.length == items.length) {
      await widget.teacher.praise(
        'আজকের পুরো learning plan complete! অসাধারণ কাজ।',
      );
    }
  }

  IconData _icon(DailyPlanItemType type) => switch (type) {
        DailyPlanItemType.review => Icons.replay_rounded,
        DailyPlanItemType.lesson => Icons.school_rounded,
        DailyPlanItemType.dictionary => Icons.menu_book_rounded,
        DailyPlanItemType.voice => Icons.mic_rounded,
        DailyPlanItemType.writing => Icons.draw_rounded,
        DailyPlanItemType.game => Icons.sports_esports_rounded,
        DailyPlanItemType.listening => Icons.headphones_rounded,
        DailyPlanItemType.conversation => Icons.forum_rounded,
        DailyPlanItemType.revision => Icons.psychology_alt_rounded,
        DailyPlanItemType.homework => Icons.assignment_rounded,
        DailyPlanItemType.pronunciation => Icons.graphic_eq_rounded,
        DailyPlanItemType.mockExam => Icons.fact_check_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final minutes = items.fold<int>(
      0,
      (sum, item) => sum + item.minutes,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Learning Plan")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TeacherViewport(teacher: widget.teacher, height: 265),
                const SizedBox(height: 14),
                Card(
                  color: const Color(0xFFFFF1C7),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: MewtionaryTheme.amber,
                      child: Icon(
                        Icons.today_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      '${widget.profile.profile.name}-এর আজকের plan',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(
                      '${items.length} tasks · প্রায় $minutes minutes',
                    ),
                  ),
                ),
                for (final item in items)
                  Card(
                    child: ListTile(
                      onTap: completed.contains(item.id)
                          ? null
                          : () => _open(item),
                      leading: CircleAvatar(
                        backgroundColor: completed.contains(item.id)
                            ? Colors.green.shade100
                            : MewtionaryTheme.teal.withOpacity(.12),
                        child: Icon(
                          completed.contains(item.id)
                              ? Icons.check_rounded
                              : _icon(item.type),
                          color: completed.contains(item.id)
                              ? Colors.green
                              : MewtionaryTheme.teal,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        '${item.subtitle} · ${item.minutes} min',
                      ),
                      trailing: completed.contains(item.id)
                          ? const Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                    ),
                  ),
              ],
            ),
    );
  }
}
