import '../data/mewtionary_database.dart';
import '../models/adaptive_learning_models.dart';
import '../models/exam_coach_models.dart';
import 'pronunciation_scoring_service.dart';

class PronunciationCoachResult {
  const PronunciationCoachResult({
    required this.score,
    required this.successful,
    required this.feedback,
  });

  final PronunciationScore score;
  final bool successful;
  final List<String> feedback;
}

class PronunciationCoachService {
  PronunciationCoachService({
    PronunciationScoringService? scoring,
    MewtionaryDatabase? database,
  })  : _scoring = scoring ?? const PronunciationScoringService(),
        _database = database ?? MewtionaryDatabase.instance;

  final PronunciationScoringService _scoring;
  final MewtionaryDatabase _database;

  Future<PronunciationCoachResult> evaluate({
    required PronunciationExercise exercise,
    required String transcript,
  }) async {
    final score = _scoring.score(
      expected: exercise.target,
      heard: transcript,
    );
    final successful = score.total >= .72;
    final feedback = <String>[];

    if (score.missingWords.isNotEmpty) {
      feedback.add(
        'Missing: ${score.missingWords.join(', ')}',
      );
    }
    if (score.extraWords.isNotEmpty) {
      feedback.add(
        'Extra: ${score.extraWords.join(', ')}',
      );
    }
    if (score.sequenceAccuracy < .7) {
      feedback.add(
        'শব্দগুলোর order ধরে ধীরে ধীরে বলো।',
      );
    }
    if (feedback.isEmpty) {
      feedback.add('Word coverage এবং sentence order ভালো হয়েছে।');
    }

    await _database.savePronunciationAttempt(
      exerciseId: exercise.id,
      transcript: transcript,
      score: score.total,
      successful: successful,
    );

    return PronunciationCoachResult(
      score: score,
      successful: successful,
      feedback: feedback,
    );
  }
}
