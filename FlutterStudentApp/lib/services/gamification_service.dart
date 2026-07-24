import 'package:flutter/foundation.dart';

import '../data/mewtionary_database.dart';
import '../models/engagement_models.dart';
import 'engagement_content_service.dart';

class GamificationService extends ChangeNotifier {
  GamificationService({
    MewtionaryDatabase? database,
    EngagementContentService? content,
  })  : _database = database ?? MewtionaryDatabase.instance,
        _content = content ?? EngagementContentService();

  final MewtionaryDatabase _database;
  final EngagementContentService _content;

  RewardWallet _wallet = const RewardWallet(
    xp: 0,
    coins: 0,
    streak: 0,
    lastActivityDate: null,
  );
  List<BadgeStatus> _badges = const [];

  RewardWallet get wallet => _wallet;
  List<BadgeStatus> get badges => List.unmodifiable(_badges);

  Future<void> load() async {
    final row = await _database.loadRewardWallet();
    if (row != null) {
      _wallet = RewardWallet.fromMap(row);
    }
    await _refreshBadges();
    notifyListeners();
  }

  Future<bool> award({
    required String sourceType,
    required String sourceId,
    required int xp,
    required int coins,
  }) async {
    final added = await _database.addReward(
      sourceType: sourceType,
      sourceId: sourceId,
      xp: xp,
      coins: coins,
    );
    if (added) {
      await load();
    }
    return added;
  }

  Future<void> _refreshBadges() async {
    final definitions = await _content.loadBadges();
    final unlocked = await _database.loadUnlockedBadges();

    final gameCount = await _database.successfulGameCount();
    final listeningCount =
        await _database.successfulListeningCount();
    final storyCount = await _database.completedAdventureCount();
    final conversationCount =
        await _database.completedConversationCount();
    final revisionCount =
        await _database.completedRevisionCount();
    final pronunciationCount =
        await _database.successfulPronunciationCount();
    final examCount =
        await _database.passedMockExamCount();
    final studyTaskCount =
        await _database.completedStudyTaskCount();

    for (final badge in definitions) {
      final achieved = switch (badge.ruleType) {
        'xp' => _wallet.xp >= badge.threshold,
        'coins' => _wallet.coins >= badge.threshold,
        'streak' => _wallet.streak >= badge.threshold,
        'games' => gameCount >= badge.threshold,
        'listening' => listeningCount >= badge.threshold,
        'stories' => storyCount >= badge.threshold,
        'conversation' =>
            conversationCount >= badge.threshold,
        'revision' => revisionCount >= badge.threshold,
        'pronunciation' =>
            pronunciationCount >= badge.threshold,
        'exam' => examCount >= badge.threshold,
        'studyTasks' =>
            studyTaskCount >= badge.threshold,
        _ => false,
      };
      if (achieved && !unlocked.containsKey(badge.id)) {
        await _database.unlockBadge(badge.id);
      }
    }

    final latest = await _database.loadUnlockedBadges();
    _badges = definitions
        .map(
          (definition) => BadgeStatus(
            definition: definition,
            unlocked: latest.containsKey(definition.id),
            unlockedAt: latest[definition.id],
          ),
        )
        .toList();
  }
}
