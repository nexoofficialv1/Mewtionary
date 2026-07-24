import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../data/mewtionary_database.dart';
import '../models/curriculum_models.dart';
import '../models/exam_coach_models.dart';
import 'exam_coach_content_service.dart';
import 'gamification_service.dart';
import 'student_profile_service.dart';

class CertificateService {
  CertificateService({
    required ExamCoachContentService content,
    required GamificationService gamification,
    required StudentProfileService profile,
    MewtionaryDatabase? database,
  })  : _content = content,
        _gamification = gamification,
        _profile = profile,
        _database = database ?? MewtionaryDatabase.instance;

  final ExamCoachContentService _content;
  final GamificationService _gamification;
  final StudentProfileService _profile;
  final MewtionaryDatabase _database;

  Future<List<CertificateStatus>> load() async {
    await _profile.load();
    await _gamification.load();
    final definitions = await _content.loadCertificates();
    final pronunciation =
        await _database.successfulPronunciationCount();
    final exams = await _database.passedMockExamCount();
    final tasks = await _database.completedStudyTaskCount();
    final issued = await _database.issuedCertificateIds();

    final statuses = <CertificateStatus>[];
    for (final definition in definitions) {
      final current = switch (definition.ruleType) {
        'xp' => _gamification.wallet.xp,
        'pronunciation' => pronunciation,
        'exam' => exams,
        'studyTasks' => tasks,
        _ => 0,
      };
      final unlocked = current >= definition.threshold;
      if (unlocked && !issued.contains(definition.id)) {
        await _database.issueCertificate(definition.id);
      }
      statuses.add(
        CertificateStatus(
          definition: definition,
          unlocked: unlocked,
          progress: definition.threshold == 0
              ? 1
              : (current / definition.threshold)
                  .clamp(0.0, 1.0)
                  .toDouble(),
        ),
      );
    }
    return statuses;
  }

  Future<String?> export(
    CertificateDefinition certificate,
  ) async {
    await _profile.load();
    final html = buildHtml(certificate);
    final safe = certificate.id.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    return FilePicker.saveFile(
      dialogTitle: 'Save certificate',
      fileName: 'Mewtionary_$safe.html',
      type: FileType.custom,
      allowedExtensions: const ['html'],
      bytes: Uint8List.fromList(utf8.encode(html)),
    );
  }

  String buildHtml(CertificateDefinition certificate) {
    final profile = _profile.profile;
    final date = DateTime.now();
    final dateText =
        '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';

    return '''<!doctype html>
<html><head><meta charset="utf-8">
<title>${_escape(certificate.title)}</title>
<style>
@page{size:A4 landscape;margin:0}
body{margin:0;font-family:Georgia,serif;background:#f5ead1;color:#17395c}
.sheet{width:297mm;height:210mm;box-sizing:border-box;padding:17mm;border:12px double #b7862f;display:flex;align-items:center;justify-content:center;text-align:center}
.inner{width:100%;height:100%;border:2px solid #167e83;padding:16mm;box-sizing:border-box}
.brand{font-family:Arial,sans-serif;letter-spacing:4px;color:#167e83;font-weight:bold}
.icon{font-size:54px}.title{font-size:34px;margin:10px}.name{font-size:36px;color:#8b5b1e;border-bottom:2px solid #8b5b1e;display:inline-block;padding:0 24px 6px}
.desc{font-size:20px;line-height:1.5}.footer{display:flex;justify-content:space-between;margin-top:35px;font-family:Arial,sans-serif}.line{border-top:1px solid #17395c;padding-top:7px;width:190px}
</style></head><body><div class="sheet"><div class="inner">
<div class="brand">MEWTIONARY LEARNING APP</div>
<div class="icon">${certificate.icon}</div>
<div class="title">${_escape(certificate.title)}</div>
<p>This certificate is proudly presented to</p>
<div class="name">${_escape(profile.name)}</div>
<p class="desc">for successfully achieving<br><b>${_escape(certificate.description)}</b><br>at ${_escape(profile.level.title)} level.</p>
<div class="footer"><div class="line">Date: $dateText</div><div class="line">Astra Technologies</div></div>
</div></div></body></html>''';
  }

  String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
