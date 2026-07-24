import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/models/exam_coach_models.dart';

void main() {
  test('parses pronunciation exercise', () {
    final item = PronunciationExercise.fromJson({
      'id': 'p1',
      'levelId': 'class_4',
      'title': 'Flower',
      'target': 'The flower is beautiful.',
      'bangla': 'ফুলটি সুন্দর।',
      'syllables': ['The', 'flow-er'],
      'focusSounds': ['/f/'],
      'mouthTip': 'Tip',
      'minimalPairs': ['fan — van'],
      'xp': 15,
      'coins': 4,
    });
    expect(item.syllables.length, 2);
    expect(item.xp, 15);
  });

  test('study task copies completion state', () {
    final task = StudyTask(
      id: 1,
      title: 'Study',
      subtitle: '',
      route: '/',
      plannedDate: DateTime(2026, 7, 24),
      minutes: 10,
      completed: false,
      source: 'manual',
    );
    expect(task.copyWith(completed: true).completed, isTrue);
  });
}
