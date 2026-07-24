import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/services/pronunciation_scoring_service.dart';

void main() {
  const service = PronunciationScoringService();

  test('gives full score for matching sentence', () {
    final result = service.score(
      expected: 'She goes to school every day.',
      heard: 'she goes to school every day',
    );

    expect(result.total, 1);
    expect(result.missingWords, isEmpty);
  });

  test('identifies missing words', () {
    final result = service.score(
      expected: 'The flower is beautiful.',
      heard: 'flower beautiful',
    );

    expect(result.total, lessThan(1));
    expect(result.missingWords, contains('the'));
    expect(result.missingWords, contains('is'));
  });
}
