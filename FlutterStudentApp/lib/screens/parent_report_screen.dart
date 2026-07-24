import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/mewtionary_theme.dart';
import '../models/tutor_studio_models.dart';
import '../services/parent_report_service.dart';

class ParentReportScreen extends StatefulWidget {
  const ParentReportScreen({
    required this.service,
    super.key,
  });

  final ParentReportService service;

  @override
  State<ParentReportScreen> createState() =>
      _ParentReportScreenState();
}

class _ParentReportScreenState extends State<ParentReportScreen> {
  ParentReportSnapshot? report;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await widget.service.load();
    if (!mounted) return;
    setState(() {
      report = value;
      loading = false;
    });
  }

  Future<void> _copy() async {
    final value = report;
    if (value == null) return;
    await Clipboard.setData(
      ClipboardData(text: widget.service.buildText(value)),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report copied')),
    );
  }

  Future<void> _exportHtml() async {
    final value = report;
    if (value == null) return;
    final path = await widget.service.exportHtml(value);
    if (!mounted || path == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('HTML report saved: $path')),
    );
  }

  Future<void> _exportCsv() async {
    final value = report;
    if (value == null) return;
    final path = await widget.service.exportCsv(value);
    if (!mounted || path == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV report saved: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = report;
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Report Export')),
      body: loading || value == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: const Color(0xFFFFF1C7),
                    child: Padding(
                      padding: const EdgeInsets.all(19),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.summarize_rounded,
                            size: 58,
                            color: MewtionaryTheme.amber,
                          ),
                          Text(
                            value.studentName,
                            style: const TextStyle(
                              fontSize: 24,
                              color: MewtionaryTheme.navy,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(value.levelTitle),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _ReportStat(
                          value:
                              '${value.completedLessons}/${value.totalLessons}',
                          label: 'Lessons',
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _ReportStat(
                          value: '${value.totalXp}',
                          label: 'XP',
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _ReportStat(
                          value: '${value.streak}',
                          label: 'Streak',
                        ),
                      ),
                    ],
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(17),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Practice Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Weekly events: ${value.weeklyEvents}',
                          ),
                          Text(
                            'Games completed: ${value.completedGames}',
                          ),
                          Text(
                            'Listening completed: '
                            '${value.completedListening}',
                          ),
                          Text(
                            'Story adventures: '
                            '${value.completedStories}',
                          ),
                          Text(
                            'Pronunciation completed: '
                            '${value.completedPronunciation}',
                          ),
                          Text(
                            'Mock exams passed: '
                            '${value.passedMockExams}',
                          ),
                          Text(
                            'Study tasks completed: '
                            '${value.completedStudyTasks}',
                          ),
                          Text(
                            'Latest revision: '
                            '${value.latestRevisionScore == null ? "Not attempted" : "${(value.latestRevisionScore! * 100).round()}%"}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'Skill Mastery',
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: MewtionaryTheme.navy,
                              fontWeight: FontWeight.w900,
                            ),
                  ),
                  for (final entry in value.skillMastery.entries)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(entry.key)),
                                Text(
                                  '${(entry.value * 100).round()}%',
                                  style: const TextStyle(
                                    color: MewtionaryTheme.teal,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            LinearProgressIndicator(
                              value: entry.value,
                              minHeight: 9,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _exportHtml,
                    icon: const Icon(Icons.web_rounded),
                    label: const Text('Export Printable HTML'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _exportCsv,
                    icon: const Icon(Icons.table_view_rounded),
                    label: const Text('Export CSV Data'),
                  ),
                  TextButton.icon(
                    onPressed: _copy,
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy Text Summary'),
                  ),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Report locally stored learning activity থেকে '
                        'তৈরি হয়। App কোনো child data নিজে থেকে internet-এ '
                        'upload করে না।',
                        style: TextStyle(
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ReportStat extends StatelessWidget {
  const _ReportStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 15,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                color: MewtionaryTheme.navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
