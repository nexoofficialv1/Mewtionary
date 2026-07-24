import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../models/adaptive_learning_models.dart';
import '../services/learning_analytics_service.dart';
import '../services/student_profile_service.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({
    required this.analytics,
    required this.profile,
    super.key,
  });

  final LearningAnalyticsService analytics;
  final StudentProfileService profile;

  @override
  State<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState
    extends State<ParentDashboardScreen> {
  LearningAnalyticsSnapshot? snapshot;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.profile.load();
    final value = await widget.analytics.load();
    if (!mounted) return;
    setState(() {
      snapshot = value;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = snapshot;

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Analytics')),
      body: loading || data == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: const Color(0xFFFFF1C7),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: MewtionaryTheme.amber,
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        widget.profile.profile.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        '${widget.profile.profile.level.title} · '
                        'Age ${widget.profile.profile.age}',
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Lessons',
                          value:
                              '${data.completedLessons}/${data.totalLessons}',
                          icon: Icons.school_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'Weekly activity',
                          value: '${data.weeklyEvents}',
                          icon: Icons.insights_rounded,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Review due',
                          value: '${data.reviewDue}',
                          icon: Icons.replay_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'Active days',
                          value: '${data.currentStreak}',
                          icon: Icons.local_fire_department_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Skill Mastery',
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: MewtionaryTheme.navy,
                              fontWeight: FontWeight.w900,
                            ),
                  ),
                  for (final skill in data.skills)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    skill.skill.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(skill.mastery * 100).round()}%',
                                  style: const TextStyle(
                                    color: MewtionaryTheme.teal,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: skill.mastery,
                              minHeight: 10,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${skill.completed}/${skill.total} sample lessons completed',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(icon, color: MewtionaryTheme.teal),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                color: MewtionaryTheme.navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
