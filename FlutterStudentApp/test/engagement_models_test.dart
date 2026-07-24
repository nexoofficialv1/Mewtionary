import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/models/engagement_models.dart';

void main() {
  test('reward wallet calculates level progress', () {
    const wallet = RewardWallet(
      xp: 245,
      coins: 20,
      streak: 3,
      lastActivityDate: null,
    );

    expect(wallet.level, 3);
    expect(wallet.xpInsideLevel, 45);
    expect(wallet.levelProgress, .45);
  });

  test('parses listening exercise', () {
    final item = ListeningExercise.fromJson({
      'id': 'listen',
      'levelId': 'class_4',
      'title': 'Listen',
      'english': 'She is reading.',
      'bangla': 'সে পড়ছে।',
      'mode': 'mcq',
      'options': ['A', 'B'],
      'correctIndex': 1,
      'xp': 10,
      'coins': 2,
    });

    expect(item.correctIndex, 1);
    expect(item.mode, 'mcq');
  });
}
