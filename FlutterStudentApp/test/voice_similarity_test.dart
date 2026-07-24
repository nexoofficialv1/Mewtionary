import 'package:flutter_test/flutter_test.dart';

Set<String> words(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z\s]'), '')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toSet();
}

double similarity(String a, String b) {
  final expected = words(a);
  final actual = words(b);
  if (expected.isEmpty || actual.isEmpty) return 0;
  final common = expected.where(actual.contains).length;
  final coverage = common / expected.length;
  final lengthScore = 1 -
      ((expected.length - actual.length).abs() /
              expected.length.clamp(1, 100))
          .clamp(0, 1);
  return (coverage * .8 + lengthScore * .2).clamp(0, 1);
}

void main() {
  test('recognises a close pronunciation transcript', () {
    final score = similarity(
      'The flower is beautiful.',
      'the flower is beautiful',
    );
    expect(score, greaterThan(.95));
  });

  test('rejects an unrelated transcript', () {
    final score = similarity(
      'The flower is beautiful.',
      'I play football',
    );
    expect(score, lessThan(.4));
  });
}
