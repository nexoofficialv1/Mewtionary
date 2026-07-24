import '../data/mewtionary_database.dart';
import '../models/curriculum_models.dart';
import '../models/exam_coach_models.dart';

class MockExamService {
  MockExamService({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;

  bool isCorrect({
    required MockExamQuestion question,
    required String answer,
  }) {
    final normalized = _normalize(answer);
    if (normalized.isEmpty) return false;

    if (question.type == ExamQuestionType.shortAnswer &&
        question.acceptedAnswers.isEmpty) {
      final words = normalized
          .split(' ')
          .where((item) => item.isNotEmpty)
          .length;
      return words >= 5 &&
          RegExp(r'[a-z]').hasMatch(normalized);
    }

    final accepted = <String>{
      _normalize(question.answer),
      ...question.acceptedAnswers.map(_normalize),
    };
    return accepted.contains(normalized);
  }

  MockExamResult evaluate({
    required MockExamPaper paper,
    required Map<String, String> answers,
  }) {
    var earnedMarks = 0;
    var correctAnswers = 0;
    final totals = <CurriculumSkill, int>{};
    final earnedBySkill = <CurriculumSkill, int>{};

    for (final question in paper.questions) {
      totals[question.skill] =
          (totals[question.skill] ?? 0) + question.marks;
      final correct = isCorrect(
        question: question,
        answer: answers[question.id] ?? '',
      );
      if (correct) {
        correctAnswers++;
        earnedMarks += question.marks;
        earnedBySkill[question.skill] =
            (earnedBySkill[question.skill] ?? 0) +
                question.marks;
      }
    }

    return MockExamResult(
      earnedMarks: earnedMarks,
      totalMarks: paper.totalMarks,
      correctAnswers: correctAnswers,
      totalQuestions: paper.questions.length,
      skillScores: {
        for (final entry in totals.entries)
          entry.key:
              (earnedBySkill[entry.key] ?? 0) / entry.value,
      },
    );
  }

  Future<void> save({
    required MockExamPaper paper,
    required MockExamResult result,
    required Map<String, String> answers,
  }) {
    return _database.saveMockExamAttempt(
      paperId: paper.id,
      earnedMarks: result.earnedMarks,
      totalMarks: result.totalMarks,
      answers: answers,
    );
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\u0980-\u09ff\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
