import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/data/content_repository.dart';
import 'package:mewtionary_student/models/learning_models.dart';

void main() {
  group('Dictionary search', () {
    const entries = [
      DictionaryEntry(
        word: 'Beautiful',
        bangla: 'সুন্দর',
        partOfSpeech: 'adjective',
        pronunciation: '',
        definition: 'Pleasing.',
        example: '',
        exampleBangla: '',
      ),
      DictionaryEntry(
        word: 'Brave',
        bangla: 'সাহসী',
        partOfSpeech: 'adjective',
        pronunciation: '',
        definition: 'Courageous.',
        example: '',
        exampleBangla: '',
      ),
    ];

    test('prioritises exact English match', () {
      final result = ContentRepository().searchDictionary(
        entries,
        'beautiful',
      );
      expect(result.first.word, 'Beautiful');
    });

    test('supports Bangla search', () {
      final result = ContentRepository().searchDictionary(
        entries,
        'সাহসী',
      );
      expect(result.single.word, 'Brave');
    });
  });
}
