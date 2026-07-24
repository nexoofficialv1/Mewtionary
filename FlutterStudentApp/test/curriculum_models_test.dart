import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/models/curriculum_models.dart';

void main() {
  test('parses curriculum lesson', () {
    final lesson = CurriculumLesson.fromJson({
      'id': 'demo',
      'title': 'Demo',
      'banglaTitle': 'ডেমো',
      'skill': 'grammar',
      'estimatedMinutes': 10,
      'teacherState': 'pointing',
      'content': {'explanation': 'Demo rule'},
      'activities': [
        {
          'question': 'Pick one',
          'options': ['A', 'B'],
          'correctIndex': 1,
        }
      ],
      'prerequisites': <String>[],
      'stars': 2,
    });

    expect(lesson.skill, CurriculumSkill.grammar);
    expect(lesson.activities.single['correctIndex'], 1);
  });
}
