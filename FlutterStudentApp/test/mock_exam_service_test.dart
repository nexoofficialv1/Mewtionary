import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/models/curriculum_models.dart';
import 'package:mewtionary_student/models/exam_coach_models.dart';
import 'package:mewtionary_student/services/mock_exam_service.dart';

void main() {
  final service = MockExamService();

  const question = MockExamQuestion(
    id: 'q1',
    type: ExamQuestionType.fillBlank,
    skill: CurriculumSkill.grammar,
    prompt: 'Past of go',
    options: [],
    answer: 'went',
    acceptedAnswers: ['went'],
    explanation: '',
    marks: 2,
  );

  test('normalizes exact accepted answer', () {
    expect(
      service.isCorrect(
        question: question,
        answer: 'Went.',
      ),
      isTrue,
    );
  });

  test('evaluates marks and skill score', () {
    const paper = MockExamPaper(
      id: 'paper',
      levelId: 'class_4',
      title: 'Paper',
      banglaTitle: 'পরীক্ষা',
      durationMinutes: 10,
      instructions: [],
      questions: [question],
      xp: 10,
      coins: 2,
    );
    final result = service.evaluate(
      paper: paper,
      answers: {'q1': 'went'},
    );
    expect(result.earnedMarks, 2);
    expect(result.percentage, 1);
  });
}
