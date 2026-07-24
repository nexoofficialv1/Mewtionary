import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/mewtionary_database.dart';
import '../models/adaptive_learning_models.dart';
import '../models/curriculum_models.dart';

class DiagnosticService {
  DiagnosticService({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;

  Future<List<DiagnosticQuestion>> loadQuestions() async {
    final raw = await rootBundle.loadString(
      'assets/content/diagnostic_questions.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded['questions'] as List<dynamic>)
        .map(
          (item) => DiagnosticQuestion.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  DiagnosticResult evaluate({
    required List<DiagnosticQuestion> questions,
    required Map<String, int> answers,
  }) {
    var correct = 0;
    final correctRanks = <int>[];
    final totals = <CurriculumSkill, int>{};
    final skillCorrect = <CurriculumSkill, int>{};

    for (final question in questions) {
      if (!answers.containsKey(question.id)) continue;
      totals[question.skill] = (totals[question.skill] ?? 0) + 1;
      final isCorrect =
          answers[question.id] == question.correctIndex;
      if (isCorrect) {
        correct++;
        correctRanks.add(question.levelRank);
        skillCorrect[question.skill] =
            (skillCorrect[question.skill] ?? 0) + 1;
      }
    }

    final answered = answers.length.clamp(1, questions.length);
    final accuracy = correct / answered;
    var rank = correctRanks.isEmpty
        ? 0
        : correctRanks.reduce((a, b) => a > b ? a : b);

    if (accuracy < .45) {
      rank -= 2;
    } else if (accuracy < .65) {
      rank -= 1;
    } else if (accuracy > .88 && rank < 9) {
      rank += 1;
    }
    rank = rank.clamp(0, 9);

    final skills = <CurriculumSkill, double>{};
    for (final entry in totals.entries) {
      skills[entry.key] =
          (skillCorrect[entry.key] ?? 0) / entry.value;
    }

    return DiagnosticResult(
      score: accuracy,
      correctAnswers: correct,
      totalQuestions: answered,
      recommendedLevel: CurriculumLevel.values[rank],
      skillScores: skills,
      completedAt: DateTime.now(),
    );
  }

  Future<void> save(DiagnosticResult result) async {
    await _database.saveDiagnosticResult(result);
    await _database.logEvent(
      type: 'diagnostic_completed',
      payload: {
        'score': result.score,
        'recommendedLevel': result.recommendedLevel.id,
      },
    );
  }
}
