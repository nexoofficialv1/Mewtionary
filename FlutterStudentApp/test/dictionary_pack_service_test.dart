import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/services/dictionary_pack_service.dart';

void main() {
  test('normalizes English search', () {
    expect(
      DictionaryPackService.normalizeEnglish('  Beautiful!  '),
      'beautiful',
    );
  });

  test('removes Bangla zero-width characters', () {
    expect(
      DictionaryPackService.normalizeBangla('সু\u200Cন্দর'),
      'সুন্দর',
    );
  });
}
