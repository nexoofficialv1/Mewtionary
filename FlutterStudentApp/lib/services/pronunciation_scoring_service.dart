import '../models/adaptive_learning_models.dart';

class PronunciationScoringService {
  const PronunciationScoringService();

  PronunciationScore score({
    required String expected,
    required String heard,
  }) {
    final target = _tokens(expected);
    final actual = _tokens(heard);

    if (target.isEmpty || actual.isEmpty) {
      return const PronunciationScore(
        total: 0,
        wordCoverage: 0,
        sequenceAccuracy: 0,
        missingWords: [],
        extraWords: [],
      );
    }

    final targetSet = target.toSet();
    final actualSet = actual.toSet();
    final missing =
        target.where((word) => !actualSet.contains(word)).toSet().toList();
    final extra =
        actual.where((word) => !targetSet.contains(word)).toSet().toList();

    final matched = target.where(actualSet.contains).length;
    final coverage = matched / target.length;

    final distance = _levenshtein(target, actual);
    final maxLength =
        target.length > actual.length ? target.length : actual.length;
    final sequence = 1 - (distance / maxLength);

    final total =
        (coverage * .65 + sequence.clamp(0, 1) * .35).clamp(0, 1);

    return PronunciationScore(
      total: total,
      wordCoverage: coverage.clamp(0, 1),
      sequenceAccuracy: sequence.clamp(0, 1),
      missingWords: missing,
      extraWords: extra,
    );
  }

  List<String> _tokens(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9'\s]"), '')
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  int _levenshtein(List<String> a, List<String> b) {
    final previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 0; i < a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0);
      current[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a[i] == b[j] ? 0 : 1;
        final deletion = previous[j + 1] + 1;
        final insertion = current[j] + 1;
        final substitution = previous[j] + cost;
        current[j + 1] = [
          deletion,
          insertion,
          substitution,
        ].reduce((x, y) => x < y ? x : y);
      }
      for (var j = 0; j < current.length; j++) {
        previous[j] = current[j];
      }
    }
    return previous.last;
  }
}
