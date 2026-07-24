import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/models/adaptive_learning_models.dart';
import 'package:mewtionary_student/services/diagnostic_service.dart';

void main() {
  test('recommends a higher level for strong performance', () {
    final questions = [
      for (var rank = 0; rank < 6; rank++)
        DiagnosticQuestion(
          id: 'q$rank',
          levelRank: rank,
          skill: CurriculumSkill.grammar,
          question: 'Q',
          options: const ['A', 'B'],
          correctIndex: 0,
          hint: '',
        ),
    ];

    final answers = {
      for (final question in questions) question.id: 0,
    };
    final result = DiagnosticService().evaluate(
      questions: questions,
      answers: answers,
    );

    expect(result.score, 1);
    expect(
      result.recommendedLevel.index,
      greaterThanOrEqualTo(CurriculumLevel.class5.index),
    );
  });
}
