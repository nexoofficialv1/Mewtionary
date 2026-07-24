import '../data/mewtionary_database.dart';
import '../models/engagement_models.dart';

class StoryAdventureService {
  StoryAdventureService({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;

  Future<void> savePage({
    required StoryAdventure story,
    required int pageIndex,
  }) {
    return _database.saveAdventureProgress(
      storyId: story.id,
      pageIndex: pageIndex,
      completed: false,
      correctAnswers: 0,
    );
  }

  Future<void> complete({
    required StoryAdventure story,
    required int correctAnswers,
  }) {
    return _database.saveAdventureProgress(
      storyId: story.id,
      pageIndex: story.pages.length - 1,
      completed: true,
      correctAnswers: correctAnswers,
    );
  }
}
