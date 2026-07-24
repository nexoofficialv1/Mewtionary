import '../data/mewtionary_database.dart';
import '../models/engagement_models.dart';

class MiniGameService {
  MiniGameService({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;

  bool checkWordMatch(
    MiniGameChallenge challenge,
    String answer,
  ) {
    return _normalise(answer) == _normalise(challenge.answer);
  }

  bool checkSpelling(
    MiniGameChallenge challenge,
    List<String> letters,
  ) {
    return _normalise(letters.join()) ==
        _normalise(challenge.answer);
  }

  bool checkSentence(
    MiniGameChallenge challenge,
    List<String> words,
  ) {
    return _normalise(words.join(' ')) ==
        _normalise(challenge.answer);
  }

  Future<void> saveAttempt({
    required MiniGameChallenge challenge,
    required bool correct,
    required int attempts,
  }) {
    return _database.saveGameAttempt(
      challengeId: challenge.id,
      gameType: challenge.type.name,
      correct: correct,
      attempts: attempts,
    );
  }

  String _normalise(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9'\s]"), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
