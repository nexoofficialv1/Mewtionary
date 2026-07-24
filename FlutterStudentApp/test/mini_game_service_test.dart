import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/models/engagement_models.dart';
import 'package:mewtionary_student/services/mini_game_service.dart';

void main() {
  final service = MiniGameService();

  const sentence = MiniGameChallenge(
    id: 'sentence',
    levelId: 'class_4',
    type: MiniGameType.sentenceBuilder,
    prompt: 'Build',
    answer: 'She is reading',
    options: ['reading', 'She', 'is'],
    hint: '',
    xp: 10,
    coins: 2,
  );

  test('checks sentence builder order', () {
    expect(
      service.checkSentence(
        sentence,
        ['She', 'is', 'reading'],
      ),
      isTrue,
    );
    expect(
      service.checkSentence(
        sentence,
        ['reading', 'She', 'is'],
      ),
      isFalse,
    );
  });

  test('checks spelling without case sensitivity', () {
    const spelling = MiniGameChallenge(
      id: 'spell',
      levelId: 'class_1',
      type: MiniGameType.spelling,
      prompt: 'Spell',
      answer: 'Cat',
      options: ['c', 'a', 't'],
      hint: '',
      xp: 10,
      coins: 2,
    );
    expect(
      service.checkSpelling(spelling, ['c', 'a', 't']),
      isTrue,
    );
  });
}
