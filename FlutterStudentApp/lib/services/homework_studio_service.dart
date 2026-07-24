import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/mewtionary_database.dart';
import '../models/tutor_studio_models.dart';
import 'app_file_service.dart';

class HomeworkReview {
  const HomeworkReview({
    required this.score,
    required this.messages,
  });

  final int score;
  final List<String> messages;
}

class HomeworkStudioService {
  HomeworkStudioService({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;

  String generate(
    HomeworkTemplate template,
    Map<String, String> values,
  ) {
    var output = template.outputTemplate;
    for (final field in template.fields) {
      output = output.replaceAll(
        '{{${field.key}}}',
        values[field.key]?.trim() ?? '',
      );
    }
    return output
        .replaceAll(RegExp(r' +\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  HomeworkReview review({
    required HomeworkTemplate template,
    required Map<String, String> values,
    required String output,
  }) {
    final messages = <String>[];
    var score = 100;

    for (final field in template.fields) {
      final value = values[field.key]?.trim() ?? '';
      if (field.required && value.isEmpty) {
        messages.add('${field.label} পূরণ করা হয়নি।');
        score -= 18;
      }
    }

    if (output.isNotEmpty &&
        !RegExp(r'^[A-Z0-9]').hasMatch(output.trim())) {
      messages.add('লেখাটি capital letter দিয়ে শুরু করো।');
      score -= 8;
    }

    if (template.type != HomeworkType.notice &&
        template.type != HomeworkType.letter &&
        output.isNotEmpty &&
        !RegExp(r'[.!?]$').hasMatch(output.trim())) {
      messages.add('শেষে সঠিক punctuation ব্যবহার করো।');
      score -= 8;
    }

    final words = output
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .toList();
    if (template.type == HomeworkType.paragraph &&
        words.length < 25) {
      messages.add('Paragraph-এ আরও supporting detail যোগ করো।');
      score -= 10;
    }
    if (template.type == HomeworkType.report &&
        words.length < 45) {
      messages.add('Report-এ participants, activities ও outcome বিস্তারিত করো।');
      score -= 10;
    }

    if (messages.isEmpty) {
      messages.add('Structure, required fields এবং punctuation ঠিক আছে।');
    }

    return HomeworkReview(
      score: score.clamp(0, 100).toInt(),
      messages: messages,
    );
  }

  Future<int> saveDraft({
    int? id,
    required HomeworkTemplate template,
    required String title,
    required String content,
  }) {
    return _database.saveHomeworkDraft(
      id: id,
      templateId: template.id,
      title: title,
      content: content,
    );
  }

  Future<List<HomeworkDraft>> loadDrafts() async {
    final rows = await _database.loadHomeworkDrafts();
    return rows.map(HomeworkDraft.fromMap).toList();
  }

  Future<void> deleteDraft(int id) {
    return _database.deleteHomeworkDraft(id);
  }

  Future<void> copyToClipboard(String content) {
    return Clipboard.setData(ClipboardData(text: content));
  }

  Future<String?> exportText({
    required String title,
    required String content,
  }) async {
    final safeName = title
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return AppFileService.saveText(
      fileName: '${safeName.isEmpty ? "homework" : safeName}.txt',
      content: content,
    );
  }
}
