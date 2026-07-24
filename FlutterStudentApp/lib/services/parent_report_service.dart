import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../data/mewtionary_database.dart';
import '../models/tutor_studio_models.dart';
import 'gamification_service.dart';
import 'learning_analytics_service.dart';
import 'student_profile_service.dart';

class ParentReportService {
  ParentReportService({
    required LearningAnalyticsService analytics,
    required GamificationService gamification,
    required StudentProfileService profile,
    MewtionaryDatabase? database,
  })  : _analytics = analytics,
        _gamification = gamification,
        _profile = profile,
        _database = database ?? MewtionaryDatabase.instance;

  final LearningAnalyticsService _analytics;
  final GamificationService _gamification;
  final StudentProfileService _profile;
  final MewtionaryDatabase _database;

  Future<ParentReportSnapshot> load() async {
    await _profile.load();
    await _gamification.load();
    final analytics = await _analytics.load();
    final games = await _database.successfulGameCount();
    final listening =
        await _database.successfulListeningCount();
    final stories = await _database.completedAdventureCount();
    final pronunciation =
        await _database.successfulPronunciationCount();
    final exams = await _database.passedMockExamCount();
    final studyTasks =
        await _database.completedStudyTaskCount();
    final revision = await _database.latestRevisionAttempt();

    return ParentReportSnapshot(
      studentName: _profile.profile.name,
      levelTitle: _profile.profile.level.title,
      generatedAt: DateTime.now(),
      totalXp: _gamification.wallet.xp,
      coins: _gamification.wallet.coins,
      streak: _gamification.wallet.streak,
      weeklyEvents: analytics.weeklyEvents,
      completedLessons: analytics.completedLessons,
      totalLessons: analytics.totalLessons,
      completedGames: games,
      completedListening: listening,
      completedStories: stories,
      completedPronunciation: pronunciation,
      passedMockExams: exams,
      completedStudyTasks: studyTasks,
      latestRevisionScore: revision == null
          ? null
          : (revision['score'] as num).toDouble(),
      skillMastery: {
        for (final skill in analytics.skills)
          skill.skill.label: skill.mastery,
      },
    );
  }

  String buildText(ParentReportSnapshot report) {
    final revision = report.latestRevisionScore == null
        ? 'Not attempted'
        : '${(report.latestRevisionScore! * 100).round()}%';
    final skills = report.skillMastery.entries
        .map(
          (entry) =>
              '${entry.key}: ${(entry.value * 100).round()}%',
        )
        .join('\n');

    return '''
MEWTIONARY PARENT PROGRESS REPORT

Student: ${report.studentName}
Learning Level: ${report.levelTitle}
Generated: ${_date(report.generatedAt)}

SUMMARY
Lessons completed: ${report.completedLessons}/${report.totalLessons}
Weekly learning events: ${report.weeklyEvents}
XP: ${report.totalXp}
Coins: ${report.coins}
Learning streak: ${report.streak} day(s)
Games completed correctly: ${report.completedGames}
Listening exercises completed correctly: ${report.completedListening}
Story adventures completed: ${report.completedStories}
Pronunciation exercises completed: ${report.completedPronunciation}
Mock exams passed: ${report.passedMockExams}
Study tasks completed: ${report.completedStudyTasks}
Latest revision score: $revision

SKILL MASTERY
$skills

Note: This report reflects activity and sample curriculum data stored locally in Mewtionary.
'''.trim();
  }

  String buildHtml(ParentReportSnapshot report) {
    final rows = report.skillMastery.entries.map((entry) {
      final score = (entry.value * 100).round();
      return '<tr><td>${_escape(entry.key)}</td>'
          '<td>$score%</td></tr>';
    }).join();

    final revision = report.latestRevisionScore == null
        ? 'Not attempted'
        : '${(report.latestRevisionScore! * 100).round()}%';

    return '''<!doctype html>
<html><head><meta charset="utf-8">
<title>Mewtionary Parent Report</title>
<style>
body{font-family:Arial,sans-serif;color:#24303c;margin:32px}
h1{color:#17395c}h2{color:#167e83;margin-top:28px}
.card{border:1px solid #d9e1e3;border-radius:14px;padding:16px;margin:12px 0}
.grid{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}
.stat{background:#f7f1e5;border-radius:12px;padding:12px;text-align:center}
.stat b{font-size:24px;color:#17395c;display:block}
table{border-collapse:collapse;width:100%}td,th{padding:10px;border-bottom:1px solid #ddd;text-align:left}
small{color:#667}
</style></head><body>
<h1>Mewtionary Parent Progress Report</h1>
<div class="card"><b>Student:</b> ${_escape(report.studentName)}<br>
<b>Learning level:</b> ${_escape(report.levelTitle)}<br>
<b>Generated:</b> ${_date(report.generatedAt)}</div>
<div class="grid">
<div class="stat"><b>${report.completedLessons}/${report.totalLessons}</b>Lessons</div>
<div class="stat"><b>${report.weeklyEvents}</b>Weekly events</div>
<div class="stat"><b>${report.streak}</b>Day streak</div>
<div class="stat"><b>${report.totalXp}</b>XP</div>
<div class="stat"><b>${report.coins}</b>Coins</div>
<div class="stat"><b>$revision</b>Revision</div>
</div>
<h2>Practice completed</h2>
<div class="card">Games: ${report.completedGames}<br>
Listening: ${report.completedListening}<br>
Story adventures: ${report.completedStories}<br>
Pronunciation exercises: ${report.completedPronunciation}<br>
Mock exams passed: ${report.passedMockExams}<br>
Study tasks completed: ${report.completedStudyTasks}</div>
<h2>Skill mastery</h2>
<table><tr><th>Skill</th><th>Mastery</th></tr>$rows</table>
<p><small>This report reflects locally stored activity and the currently installed curriculum content.</small></p>
</body></html>''';
  }

  String buildCsv(ParentReportSnapshot report) {
    final rows = <List<String>>[
      ['Field', 'Value'],
      ['Student', report.studentName],
      ['Learning Level', report.levelTitle],
      ['Generated', _date(report.generatedAt)],
      ['Lessons Completed', '${report.completedLessons}'],
      ['Total Lessons', '${report.totalLessons}'],
      ['Weekly Events', '${report.weeklyEvents}'],
      ['XP', '${report.totalXp}'],
      ['Coins', '${report.coins}'],
      ['Streak', '${report.streak}'],
      ['Games', '${report.completedGames}'],
      ['Listening', '${report.completedListening}'],
      ['Stories', '${report.completedStories}'],
      ['Pronunciation', '${report.completedPronunciation}'],
      ['Mock Exams Passed', '${report.passedMockExams}'],
      ['Study Tasks Completed', '${report.completedStudyTasks}'],
      [
        'Latest Revision',
        report.latestRevisionScore == null
            ? ''
            : '${(report.latestRevisionScore! * 100).round()}%',
      ],
      for (final entry in report.skillMastery.entries)
        [
          'Skill ${entry.key}',
          '${(entry.value * 100).round()}%',
        ],
    ];

    return rows.map(
      (row) => row.map(_csv).join(','),
    ).join('\n');
  }

  Future<String?> exportHtml(
    ParentReportSnapshot report,
  ) {
    return FilePicker.platform.saveFile(
      dialogTitle: 'Save parent report',
      fileName: 'mewtionary_parent_report.html',
      type: FileType.custom,
      allowedExtensions: const ['html'],
      bytes: Uint8List.fromList(
        utf8.encode(buildHtml(report)),
      ),
    );
  }

  Future<String?> exportCsv(
    ParentReportSnapshot report,
  ) {
    return FilePicker.platform.saveFile(
      dialogTitle: 'Save parent report data',
      fileName: 'mewtionary_parent_report.csv',
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      bytes: Uint8List.fromList(
        utf8.encode(buildCsv(report)),
      ),
    );
  }

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day-$month-${value.year}';
  }

  String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  String _csv(String value) =>
      '"${value.replaceAll('"', '""')}"';
}
