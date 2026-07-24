import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/curriculum_models.dart';
import '../models/tutor_studio_models.dart';

class TutorStudioContentService {
  Future<List<ConversationScenario>> loadConversations(
    CurriculumLevel level,
  ) async {
    final raw = await rootBundle.loadString(
      'assets/content/conversation_scenarios.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final all = (decoded['scenarios'] as List<dynamic>)
        .map(
          (item) => ConversationScenario.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    final exact =
        all.where((item) => item.levelId == level.id).toList();
    if (exact.isNotEmpty) return exact;

    final currentRank = level.index;
    all.sort((a, b) {
      final aRank = CurriculumLevel.values
          .indexWhere((item) => item.id == a.levelId);
      final bRank = CurriculumLevel.values
          .indexWhere((item) => item.id == b.levelId);
      return (aRank - currentRank)
          .abs()
          .compareTo((bRank - currentRank).abs());
    });
    return all.take(3).toList();
  }

  Future<List<HomeworkTemplate>> loadHomeworkTemplates(
    CurriculumLevel level,
  ) async {
    final raw = await rootBundle.loadString(
      'assets/content/homework_templates.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final all = (decoded['templates'] as List<dynamic>)
        .map(
          (item) => HomeworkTemplate.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    final accessible = all.where((template) {
      final templateRank = CurriculumLevel.values
          .indexWhere((item) => item.id == template.levelId);
      return templateRank <= level.index;
    }).toList();
    return accessible.isEmpty ? all.take(2).toList() : accessible;
  }

  Future<List<RevisionQuestion>> loadRevisionQuestions() async {
    final raw = await rootBundle.loadString(
      'assets/content/revision_questions.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded['questions'] as List<dynamic>)
        .map(
          (item) => RevisionQuestion.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
