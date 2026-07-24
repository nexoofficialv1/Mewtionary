import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/curriculum_models.dart';
import '../models/exam_coach_models.dart';

class ExamCoachContentService {
  Future<List<PronunciationExercise>> loadPronunciation(
    CurriculumLevel level,
  ) async {
    final raw = await rootBundle.loadString(
      'assets/content/pronunciation_lessons.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final all = (decoded['exercises'] as List<dynamic>)
        .map(
          (item) => PronunciationExercise.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    final accessible = all.where((exercise) {
      final rank = CurriculumLevel.values.indexWhere(
        (item) => item.id == exercise.levelId,
      );
      return rank >= 0 && rank <= level.index;
    }).toList();

    accessible.sort((a, b) {
      final aRank = CurriculumLevel.values.indexWhere(
        (item) => item.id == a.levelId,
      );
      final bRank = CurriculumLevel.values.indexWhere(
        (item) => item.id == b.levelId,
      );
      return bRank.compareTo(aRank);
    });
    return accessible;
  }

  Future<List<MockExamPaper>> loadExams(
    CurriculumLevel level,
  ) async {
    final raw = await rootBundle.loadString(
      'assets/content/mock_exams.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final all = (decoded['papers'] as List<dynamic>)
        .map(
          (item) => MockExamPaper.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    final accessible = all.where((paper) {
      final rank = CurriculumLevel.values.indexWhere(
        (item) => item.id == paper.levelId,
      );
      return rank >= 0 && rank <= level.index;
    }).toList();

    if (accessible.isEmpty) return all.take(1).toList();
    accessible.sort((a, b) {
      final aRank = CurriculumLevel.values.indexWhere(
        (item) => item.id == a.levelId,
      );
      final bRank = CurriculumLevel.values.indexWhere(
        (item) => item.id == b.levelId,
      );
      return bRank.compareTo(aRank);
    });
    return accessible;
  }

  Future<List<CertificateDefinition>> loadCertificates() async {
    final raw = await rootBundle.loadString(
      'assets/content/certificates.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded['certificates'] as List<dynamic>)
        .map(
          (item) => CertificateDefinition.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
