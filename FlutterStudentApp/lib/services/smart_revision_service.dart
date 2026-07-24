import 'dart:math';

import '../data/mewtionary_database.dart';
import '../models/curriculum_models.dart';
import '../models/tutor_studio_models.dart';

class SmartRevisionService {
  SmartRevisionService({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;

  List<RevisionQuestion> buildQuiz({
    required List<RevisionQuestion> all,
    required CurriculumLevel level,
    required List<CurriculumSkill> weakSkills,
    int count = 8,
  }) {
    final accessible = all.where((question) {
      final rank = CurriculumLevel.values
          .indexWhere((item) => item.id == question.levelId);
      return rank >= 0 && rank <= level.index;
    }).toList();

    final seed = DateTime.now().year * 1000 +
        DateTime.now().month * 50 +
        DateTime.now().day +
        level.index;
    accessible.shuffle(Random(seed));

    accessible.sort((a, b) {
      final aWeak = weakSkills.indexOf(a.skill);
      final bWeak = weakSkills.indexOf(b.skill);
      final aRank = aWeak < 0 ? 999 : aWeak;
      final bRank = bWeak < 0 ? 999 : bWeak;
      return aRank.compareTo(bRank);
    });

    return accessible.take(count).toList();
  }

  RevisionResult evaluate({
    required List<RevisionQuestion> questions,
    required Map<String, int> answers,
  }) {
    var correct = 0;
    final totals = <CurriculumSkill, int>{};
    final skillCorrect = <CurriculumSkill, int>{};

    for (final question in questions) {
      totals[question.skill] = (totals[question.skill] ?? 0) + 1;
      final isCorrect =
          answers[question.id] == question.correctIndex;
      if (isCorrect) {
        correct++;
        skillCorrect[question.skill] =
            (skillCorrect[question.skill] ?? 0) + 1;
      }
    }

    final scores = <CurriculumSkill, double>{};
    for (final entry in totals.entries) {
      scores[entry.key] =
          (skillCorrect[entry.key] ?? 0) / entry.value;
    }

    return RevisionResult(
      correct: correct,
      total: questions.length,
      skillScores: scores,
    );
  }

  Future<void> save({
    required CurriculumLevel level,
    required RevisionResult result,
  }) {
    return _database.saveRevisionAttempt(
      levelId: level.id,
      correctAnswers: result.correct,
      totalQuestions: result.total,
      skillScores: result.skillScores.map(
        (key, value) => MapEntry(key.name, value),
      ),
    );
  }
}
