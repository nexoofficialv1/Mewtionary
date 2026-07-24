import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../core/mewtionary_theme.dart';
import '../models/exam_coach_models.dart';
import '../services/gamification_service.dart';
import '../services/study_planner_service.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({
    required this.service,
    required this.gamification,
    super.key,
  });

  final StudyPlannerService service;
  final GamificationService gamification;

  @override
  State<StudyPlannerScreen> createState() =>
      _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  DateTime selectedWeek = DateTime.now();
  List<StudyTask> tasks = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load(generate: true);
  }

  Future<void> _load({bool generate = false}) async {
    setState(() => loading = true);
    if (generate) {
      await widget.service.generateWeek(selectedWeek);
    }
    final data = await widget.service.loadWeek(selectedWeek);
    if (!mounted) return;
    setState(() {
      tasks = data;
      loading = false;
    });
  }

  Future<void> _toggle(StudyTask task, bool value) async {
    await widget.service.setCompleted(task, value);
    if (value) {
      await widget.gamification.award(
        sourceType: 'study_task',
        sourceId: 'study_${task.id}',
        xp: 5,
        coins: 1,
      );
    }
    await _load();
  }

  Future<void> _addTask() async {
    final title = TextEditingController();
    final subtitle = TextEditingController();
    final minutes = TextEditingController(text: '15');
    DateTime date = DateTime.now();
    String route = AppRoutes.smartRevision;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Study Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                  ),
                ),
                TextField(
                  controller: subtitle,
                  decoration: const InputDecoration(
                    labelText: 'Details',
                  ),
                ),
                TextField(
                  controller: minutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutes',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: route,
                  decoration: const InputDecoration(
                    labelText: 'Open module',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AppRoutes.smartRevision,
                      child: Text('Smart Revision'),
                    ),
                    DropdownMenuItem(
                      value: AppRoutes.pronunciationCoach,
                      child: Text('Pronunciation Coach'),
                    ),
                    DropdownMenuItem(
                      value: AppRoutes.mockExam,
                      child: Text('Mock Exam'),
                    ),
                    DropdownMenuItem(
                      value: AppRoutes.learningPath,
                      child: Text('Learning Path'),
                    ),
                    DropdownMenuItem(
                      value: AppRoutes.conversationLab,
                      child: Text('Conversation Lab'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => route = value);
                    }
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Planned date'),
                  subtitle: Text(_date(date)),
                  trailing: IconButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 30),
                        ),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365),
                        ),
                        initialDate: date,
                      );
                      if (picked != null) {
                        setDialogState(() => date = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_month_rounded),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (created == true && title.text.trim().isNotEmpty) {
      await widget.service.addTask(
        StudyTask(
          id: null,
          title: title.text.trim(),
          subtitle: subtitle.text.trim(),
          route: route,
          plannedDate: date,
          minutes: int.tryParse(minutes.text) ?? 15,
          completed: false,
          source: 'manual',
        ),
      );
      await _load();
    }

    title.dispose();
    subtitle.dispose();
    minutes.dispose();
  }

  void _changeWeek(int days) {
    setState(() {
      selectedWeek =
          selectedWeek.add(Duration(days: days));
    });
    _load(generate: true);
  }

  static String _date(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((task) => task.completed).length;
    final totalMinutes = tasks.fold<int>(
      0,
      (sum, task) => sum + task.minutes,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Study Planner'),
        actions: [
          IconButton(
            onPressed: _addTask,
            icon: const Icon(Icons.add_task_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: const Color(0xFFFFF1C7),
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _changeWeek(-7),
                              icon: const Icon(
                                Icons.chevron_left_rounded,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Week of ${_date(_weekStart(selectedWeek))}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: MewtionaryTheme.navy,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _changeWeek(7),
                              icon: const Icon(
                                Icons.chevron_right_rounded,
                              ),
                            ),
                          ],
                        ),
                        LinearProgressIndicator(
                          value: tasks.isEmpty
                              ? 0
                              : completed / tasks.length,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completed/${tasks.length} tasks · '
                          '$totalMinutes planned minutes',
                        ),
                      ],
                    ),
                  ),
                ),
                if (tasks.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(22),
                      child: Text(
                        'No tasks in this week. Use + to add one.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                for (final task in tasks)
                  Dismissible(
                    key: ValueKey(task.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.only(right: 22),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) async {
                      await widget.service.delete(task);
                      await _load();
                    },
                    child: Card(
                      child: CheckboxListTile(
                        value: task.completed,
                        onChanged: (value) {
                          _toggle(task, value ?? false);
                        },
                        secondary: CircleAvatar(
                          backgroundColor: task.completed
                              ? Colors.green.withOpacity(.15)
                              : MewtionaryTheme.teal.withOpacity(.12),
                          child: Icon(
                            task.completed
                                ? Icons.check_rounded
                                : Icons.schedule_rounded,
                            color: task.completed
                                ? Colors.green
                                : MewtionaryTheme.teal,
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          '${_date(task.plannedDate)} · '
                          '${task.minutes} min\n${task.subtitle}',
                        ),
                        isThreeLine: true,
                        controlAffinity:
                            ListTileControlAffinity.trailing,
                      ),
                    ),
                  ),
                if (tasks.isNotEmpty)
                  FilledButton.icon(
                    onPressed: () {
                      final pending = tasks.firstWhere(
                        (task) => !task.completed,
                        orElse: () => tasks.first,
                      );
                      if (pending.route.isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          pending.route,
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Open Next Planned Module'),
                  ),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Planner offline task tracking করে। Device notification '
                      'বা alarm এখনো যুক্ত নয়।',
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

  DateTime _weekStart(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return date.subtract(
      Duration(days: date.weekday - DateTime.monday),
    );
  }
}
