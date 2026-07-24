import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/curriculum_models.dart';
import '../models/engagement_models.dart';

class EngagementContentService {
  Future<List<MiniGameChallenge>> loadGames(
    CurriculumLevel level,
  ) async {
    final raw = await rootBundle.loadString(
      'assets/content/mini_games.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final all = (decoded['challenges'] as List<dynamic>)
        .map(
          (item) => MiniGameChallenge.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    final exact = all
        .where((challenge) => challenge.levelId == level.id)
        .toList();
    return exact.isEmpty ? all.take(6).toList() : exact;
  }

  Future<List<ListeningExercise>> loadListening(
    CurriculumLevel level,
  ) async {
    final raw = await rootBundle.loadString(
      'assets/content/listening_exercises.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final all = (decoded['exercises'] as List<dynamic>)
        .map(
          (item) => ListeningExercise.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    final exact = all
        .where((exercise) => exercise.levelId == level.id)
        .toList();
    return exact.isEmpty ? all.take(5).toList() : exact;
  }

  Future<List<StoryAdventure>> loadAdventures(
    CurriculumLevel level,
  ) async {
    final raw = await rootBundle.loadString(
      'assets/content/story_adventures.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final all = (decoded['stories'] as List<dynamic>)
        .map(
          (item) => StoryAdventure.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    final exact = all
        .where((story) => story.levelId == level.id)
        .toList();
    return exact.isEmpty ? all : exact;
  }

  Future<List<BadgeDefinition>> loadBadges() async {
    final raw = await rootBundle.loadString(
      'assets/content/badges.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded['badges'] as List<dynamic>)
        .map(
          (item) => BadgeDefinition.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
