import 'dart:math';

import '../data/mewtionary_database.dart';
import '../models/tutor_studio_models.dart';

class ConversationEvaluation {
  const ConversationEvaluation({
    required this.reply,
    required this.score,
    required this.coverage,
    required this.missingKeywords,
  });

  final ConversationReply reply;
  final int score;
  final double coverage;
  final List<String> missingKeywords;

  bool get accepted => coverage >= .55;
}

class ConversationTutorService {
  ConversationTutorService({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;

  ConversationEvaluation evaluate({
    required ConversationNode node,
    required String answer,
  }) {
    if (node.replies.isEmpty) {
      throw StateError('This conversation node has no replies.');
    }

    final answerTokens = _tokens(answer);
    ConversationReply best = node.replies.first;
    var bestCoverage = -1.0;
    var bestMissing = <String>[];

    for (final reply in node.replies) {
      final keywords = reply.expectedKeywords
          .map((item) => item.toLowerCase())
          .toList();
      final matched = keywords
          .where((keyword) => answerTokens.contains(keyword))
          .length;
      final coverage =
          keywords.isEmpty ? 1.0 : matched / keywords.length;
      if (coverage > bestCoverage) {
        best = reply;
        bestCoverage = coverage;
        bestMissing = keywords
            .where((keyword) => !answerTokens.contains(keyword))
            .toList();
      }
    }

    final safeCoverage =
        bestCoverage.clamp(0.0, 1.0).toDouble();
    return ConversationEvaluation(
      reply: best,
      score: (best.score * safeCoverage).round(),
      coverage: safeCoverage,
      missingKeywords: bestMissing,
    );
  }

  Future<void> saveAttempt({
    required ConversationScenario scenario,
    required int score,
    required List<Map<String, dynamic>> transcript,
  }) {
    final maxScore = scenario.nodes.fold<int>(
      0,
      (sum, node) => sum +
          (node.replies.isEmpty
              ? 0
              : node.replies
                  .map((reply) => reply.score)
                  .reduce(max)),
    );
    return _database.saveConversationAttempt(
      scenarioId: scenario.id,
      score: score,
      maxScore: maxScore,
      transcript: transcript,
    );
  }

  Set<String> _tokens(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9'\s]"), '')
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .toSet();
  }
}
