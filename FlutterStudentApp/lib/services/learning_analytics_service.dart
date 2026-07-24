import '../curriculum/curriculum_engine.dart';
import '../curriculum/curriculum_repository.dart';
import '../data/mewtionary_database.dart';
import '../models/adaptive_learning_models.dart';

class LearningAnalyticsService {
  LearningAnalyticsService({
    required CurriculumRepository repository,
    required CurriculumEngine engine,
    MewtionaryDatabase? database,
  })  : _repository = repository,
        _engine = engine,
        _database = database ?? MewtionaryDatabase.instance;

  final CurriculumRepository _repository;
  final CurriculumEngine _engine;
  final MewtionaryDatabase _database;

  Future<LearningAnalyticsSnapshot> load() async {
    final units = await _repository.loadAll();
    await _engine.load();

    final now = DateTime.now();
    final events = await _database.recentEvents(
      since: now.subtract(const Duration(days: 7)),
    );

    final lessons = [
      for (final unit in units) ...unit.lessons,
    ];
    final completed = lessons
        .where((lesson) => _engine.progressFor(lesson.id).completed)
        .length;
    final reviewDue = lessons.where((lesson) {
      final record = _engine.progressFor(lesson.id);
      return record.completed &&
          record.nextReviewAt != null &&
          !record.nextReviewAt!.isAfter(now);
    }).length;

    final skills = <SkillAnalytics>[];
    for (final skill in CurriculumSkill.values) {
      final skillLessons =
          lessons.where((lesson) => lesson.skill == skill).toList();
      final completedLessons = skillLessons.where(
        (lesson) => _engine.progressFor(lesson.id).completed,
      );
      final completedList = completedLessons.toList();
      final mastery = completedList.isEmpty
          ? 0.0
          : completedList
                  .map(
                    (lesson) =>
                        _engine.progressFor(lesson.id).mastery,
                  )
                  .reduce((a, b) => a + b) /
              completedList.length;
      skills.add(
        SkillAnalytics(
          skill: skill,
          mastery: mastery,
          completed: completedList.length,
          total: skillLessons.length,
        ),
      );
    }

    final days = <String>{};
    for (final event in events) {
      final raw = event['created_at'] as String? ?? '';
      final date = DateTime.tryParse(raw);
      if (date != null) {
        days.add('${date.year}-${date.month}-${date.day}');
      }
    }

    return LearningAnalyticsSnapshot(
      completedLessons: completed,
      totalLessons: lessons.length,
      weeklyEvents: events.length,
      reviewDue: reviewDue,
      currentStreak: days.length,
      skills: skills,
    );
  }
}
