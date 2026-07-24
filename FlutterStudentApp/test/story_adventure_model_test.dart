import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/models/engagement_models.dart';

void main() {
  test('parses story adventure', () {
    final story = StoryAdventure.fromJson({
      'id': 'story',
      'levelId': 'class_4',
      'title': 'Story',
      'banglaTitle': 'গল্প',
      'summary': 'Summary',
      'pages': [
        {
          'english': 'A line.',
          'bangla': 'একটি লাইন।',
          'teacherState': 'reading',
        }
      ],
      'vocabulary': [
        {'word': 'line', 'bangla': 'লাইন'}
      ],
      'questions': [
        {
          'question': 'Q',
          'options': ['A', 'B'],
          'correctIndex': 0,
          'hint': 'Hint',
        }
      ],
      'moral': 'Moral',
      'xp': 20,
      'coins': 5,
    });

    expect(story.pages.length, 1);
    expect(story.questions.length, 1);
    expect(story.vocabulary.single.word, 'line');
  });
}
