import '../app/routes.dart';
import '../curriculum/curriculum_engine.dart';
import '../curriculum/curriculum_repository.dart';
import '../data/mewtionary_database.dart';
import '../models/adaptive_learning_models.dart';
import 'parent_control_service.dart';

class DailyPlanService {
  DailyPlanService({
    required CurriculumRepository repository,
    required CurriculumEngine engine,
    required ParentControlService parentControls,
    MewtionaryDatabase? database,
  })  : _repository = repository,
        _engine = engine,
        _parentControls = parentControls,
        _database = database ?? MewtionaryDatabase.instance;

  final CurriculumRepository _repository;
  final CurriculumEngine _engine;
  final ParentControlService _parentControls;
  final MewtionaryDatabase _database;

  Future<List<DailyPlanItem>> build(
    CurriculumLevel level,
  ) async {
    final units = await _repository.loadLevel(level);
    await _engine.load();
    await _parentControls.load();

    final budget = _parentControls.state.dailyMinutes;
    final review = _engine.reviewQueue(units);
    final next = _engine.nextLesson(units);
    final items = <DailyPlanItem>[];
    var used = 0;

    if (review.isNotEmpty && used + 7 <= budget) {
      final lesson = review.first;
      items.add(
        DailyPlanItem(
          id: 'review_${lesson.id}',
          title: 'Quick Revision',
          subtitle: lesson.banglaTitle,
          minutes: 7,
          type: DailyPlanItemType.review,
          route: AppRoutes.learningPath,
          lessonId: lesson.id,
        ),
      );
      used += 7;
    }

    if (next != null && used + next.estimatedMinutes <= budget) {
      items.add(
        DailyPlanItem(
          id: 'lesson_${next.id}',
          title: next.title,
          subtitle: next.banglaTitle,
          minutes: next.estimatedMinutes,
          type: DailyPlanItemType.lesson,
          route: AppRoutes.learningPath,
          lessonId: next.id,
        ),
      );
      used += next.estimatedMinutes;
    }

    if (used + 5 <= budget) {
      items.add(
        const DailyPlanItem(
          id: 'dictionary_daily',
          title: '5 New Words',
          subtitle: 'Teacher-এর সঙ্গে শব্দ শেখা',
          minutes: 5,
          type: DailyPlanItemType.dictionary,
          route: AppRoutes.dictionary,
        ),
      );
      used += 5;
    }


    final useConversation = DateTime.now().day.isEven;
    if (used + 7 <= budget) {
      items.add(
        DailyPlanItem(
          id: useConversation
              ? 'conversation_daily'
              : 'smart_revision_daily',
          title: useConversation
              ? 'Conversation Practice'
              : 'Smart Revision',
          subtitle: useConversation
              ? 'বাস্তব পরিস্থিতিতে guided English dialogue'
              : 'দুর্বল skill আগে রেখে revision quiz',
          minutes: 7,
          type: useConversation
              ? DailyPlanItemType.conversation
              : DailyPlanItemType.revision,
          route: useConversation
              ? AppRoutes.conversationLab
              : AppRoutes.smartRevision,
        ),
      );
      used += 7;
    }


    if (used + 7 <= budget) {
      final useExam = DateTime.now().weekday == DateTime.friday ||
          DateTime.now().weekday == DateTime.saturday;
      items.add(
        DailyPlanItem(
          id: useExam
              ? 'mock_exam_daily'
              : 'pronunciation_daily',
          title: useExam
              ? 'Mock Exam Practice'
              : 'Pronunciation Coach',
          subtitle: useExam
              ? 'Class-wise timed question practice'
              : 'Sound, syllable ও clear sentence practice',
          minutes: 7,
          type: useExam
              ? DailyPlanItemType.mockExam
              : DailyPlanItemType.pronunciation,
          route: useExam
              ? AppRoutes.mockExam
              : AppRoutes.pronunciationCoach,
        ),
      );
      used += 7;
    }

    if (used + 7 <= budget) {
      items.add(
        const DailyPlanItem(
          id: 'listening_daily',
          title: 'Listening Lab',
          subtitle: 'শুনে answer অথবা dictation practice',
          minutes: 7,
          type: DailyPlanItemType.listening,
          route: AppRoutes.listeningLab,
        ),
      );
      used += 7;
    }

    if (used + 6 <= budget) {
      items.add(
        const DailyPlanItem(
          id: 'game_daily',
          title: 'Learning Game',
          subtitle: 'Word, spelling অথবা sentence challenge',
          minutes: 6,
          type: DailyPlanItemType.game,
          route: AppRoutes.learningGames,
        ),
      );
      used += 6;
    }

    if (used + 8 <= budget) {
      items.add(
        const DailyPlanItem(
          id: 'writing_daily',
          title: 'Writing Practice',
          subtitle: 'Letter, word অথবা sentence trace',
          minutes: 8,
          type: DailyPlanItemType.writing,
          route: AppRoutes.writingPractice,
        ),
      );
      used += 8;
    }


    if (budget >= 45 && used + 10 <= budget) {
      items.add(
        const DailyPlanItem(
          id: 'homework_studio_daily',
          title: 'Homework Studio',
          subtitle: 'Guided paragraph, letter, notice অথবা report',
          minutes: 10,
          type: DailyPlanItemType.homework,
          route: AppRoutes.homeworkStudio,
        ),
      );
      used += 10;
    }

    if (items.isEmpty) {
      items.add(
        const DailyPlanItem(
          id: 'dictionary_short',
          title: 'Quick Word Practice',
          subtitle: 'আজ ৫ মিনিট শব্দ practice',
          minutes: 5,
          type: DailyPlanItemType.dictionary,
          route: AppRoutes.dictionary,
        ),
      );
    }

    return items;
  }

  Future<Set<String>> completedToday() {
    return _database.todayCompletedPlanItems();
  }

  Future<void> markComplete(String itemId) {
    return _database.markDailyPlanItemComplete(itemId);
  }
}
