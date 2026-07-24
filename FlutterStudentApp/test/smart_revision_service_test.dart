import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/models/curriculum_models.dart';
import 'package:mewtionary_student/models/tutor_studio_models.dart';
import 'package:mewtionary_student/services/smart_revision_service.dart';

void main() {
  final service = SmartRevisionService();

  test('evaluates revision skill scores', () {
    const questions = [
      RevisionQuestion(
        id: 'g1',
        levelId: 'class_4',
        skill: CurriculumSkill.grammar,
        prompt: 'Q1',
        options: ['A', 'B'],
        correctIndex: 0,
        explanation: '',
      ),
      RevisionQuestion(
        id: 'v1',
        levelId: 'class_4',
        skill: CurriculumSkill.vocabulary,
        prompt: 'Q2',
        options: ['A', 'B'],
        correctIndex: 1,
        explanation: '',
      ),
    ];

    final result = service.evaluate(
      questions: questions,
      answers: {'g1': 0, 'v1': 0},
    );

    expect(result.correct, 1);
    expect(
      result.skillScores[CurriculumSkill.grammar],
      1,
    );
    expect(
      result.skillScores[CurriculumSkill.vocabulary],
      0,
    );
  });
}
