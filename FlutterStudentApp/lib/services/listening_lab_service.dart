import '../data/mewtionary_database.dart';
import '../models/engagement_models.dart';
import 'pronunciation_scoring_service.dart';

class ListeningLabService {
  ListeningLabService({
    MewtionaryDatabase? database,
    PronunciationScoringService? scoring,
  })  : _database = database ?? MewtionaryDatabase.instance,
        _scoring = scoring ?? const PronunciationScoringService();

  final MewtionaryDatabase _database;
  final PronunciationScoringService _scoring;

  bool checkChoice(ListeningExercise exercise, int answer) {
    return exercise.correctIndex == answer;
  }

  double scoreDictation(
    ListeningExercise exercise,
    String transcript,
  ) {
    return _scoring
        .score(expected: exercise.english, heard: transcript)
        .total;
  }

  Future<void> save({
    required ListeningExercise exercise,
    required bool correct,
    required String transcript,
    required double score,
  }) {
    return _database.saveListeningAttempt(
      exerciseId: exercise.id,
      correct: correct,
      transcript: transcript,
      score: score,
    );
  }
}
