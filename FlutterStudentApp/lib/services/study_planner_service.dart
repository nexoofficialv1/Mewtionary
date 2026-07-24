import '../app/routes.dart';
import '../data/mewtionary_database.dart';
import '../models/curriculum_models.dart';
import '../models/exam_coach_models.dart';
import '../models/tutor_studio_models.dart';
import 'learning_analytics_service.dart';

class StudyPlannerService {
  StudyPlannerService({
    required LearningAnalyticsService analytics,
    MewtionaryDatabase? database,
  })  : _analytics = analytics,
        _database = database ?? MewtionaryDatabase.instance;

  final LearningAnalyticsService _analytics;
  final MewtionaryDatabase _database;

  Future<List<StudyTask>> loadWeek(DateTime day) async {
    final start = _startOfWeek(day);
    final end = start.add(const Duration(days: 7));
    final rows = await _database.loadStudyTasks(
      from: start,
      to: end,
    );
    return rows.map(StudyTask.fromMap).toList();
  }

  Future<void> generateWeek(DateTime day) async {
    final current = await loadWeek(day);
    if (current.isNotEmpty) return;

    final analytics = await _analytics.load();
    final skills = [...analytics.skills]
      ..sort((a, b) => a.mastery.compareTo(b.mastery));
    final weakSkill = skills.isEmpty
        ? 'English'
        : skills.first.skill.label;

    final start = _startOfWeek(day);
    final templates = <StudyTask>[
      StudyTask(
        id: null,
        title: 'Smart Revision',
        subtitle: '$weakSkill skill revision',
        route: AppRoutes.smartRevision,
        plannedDate: start,
        minutes: 15,
        completed: false,
        source: 'auto',
      ),
      StudyTask(
        id: null,
        title: 'Pronunciation Coach',
        subtitle: 'Sound, syllable and sentence practice',
        route: AppRoutes.pronunciationCoach,
        plannedDate: start.add(const Duration(days: 1)),
        minutes: 12,
        completed: false,
        source: 'auto',
      ),
      StudyTask(
        id: null,
        title: 'Learning Path',
        subtitle: 'Continue the next class lesson',
        route: AppRoutes.learningPath,
        plannedDate: start.add(const Duration(days: 2)),
        minutes: 20,
        completed: false,
        source: 'auto',
      ),
      StudyTask(
        id: null,
        title: 'Conversation Lab',
        subtitle: 'Guided real-life dialogue',
        route: AppRoutes.conversationLab,
        plannedDate: start.add(const Duration(days: 3)),
        minutes: 15,
        completed: false,
        source: 'auto',
      ),
      StudyTask(
        id: null,
        title: 'Mock Exam',
        subtitle: 'Timed class-wise practice paper',
        route: AppRoutes.mockExam,
        plannedDate: start.add(const Duration(days: 4)),
        minutes: 25,
        completed: false,
        source: 'auto',
      ),
      StudyTask(
        id: null,
        title: 'Story Adventure',
        subtitle: 'Read, listen and answer',
        route: AppRoutes.storyAdventures,
        plannedDate: start.add(const Duration(days: 5)),
        minutes: 15,
        completed: false,
        source: 'auto',
      ),
      StudyTask(
        id: null,
        title: 'Weekly Review',
        subtitle: 'Review rewards and progress',
        route: AppRoutes.rewards,
        plannedDate: start.add(const Duration(days: 6)),
        minutes: 10,
        completed: false,
        source: 'auto',
      ),
    ];

    for (final task in templates) {
      await addTask(task);
    }
  }

  Future<int> addTask(StudyTask task) {
    return _database.addStudyTask(
      title: task.title,
      subtitle: task.subtitle,
      route: task.route,
      plannedDate: task.plannedDate,
      minutes: task.minutes,
      source: task.source,
    );
  }

  Future<void> setCompleted(
    StudyTask task,
    bool completed,
  ) async {
    if (task.id == null) return;
    await _database.setStudyTaskCompleted(
      id: task.id!,
      completed: completed,
    );
  }

  Future<void> delete(StudyTask task) async {
    if (task.id == null) return;
    await _database.deleteStudyTask(task.id!);
  }

  DateTime _startOfWeek(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return date.subtract(
      Duration(days: date.weekday - DateTime.monday),
    );
  }
}
