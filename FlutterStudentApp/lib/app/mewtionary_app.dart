import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../screens/certificate_studio_screen.dart';
import '../screens/mock_exam_screen.dart';
import '../screens/pronunciation_coach_screen.dart';
import '../screens/study_planner_screen.dart';
import '../services/certificate_service.dart';
import '../services/exam_coach_content_service.dart';
import '../services/mock_exam_service.dart';
import '../services/pronunciation_coach_service.dart';
import '../services/study_planner_service.dart';
import '../screens/conversation_lab_screen.dart';
import '../screens/homework_studio_screen.dart';
import '../screens/parent_report_screen.dart';
import '../screens/smart_revision_screen.dart';
import '../services/conversation_tutor_service.dart';
import '../services/homework_studio_service.dart';
import '../services/parent_report_service.dart';
import '../services/smart_revision_service.dart';
import '../services/tutor_studio_content_service.dart';
import '../screens/learning_games_screen.dart';
import '../screens/listening_lab_screen.dart';
import '../screens/rewards_screen.dart';
import '../screens/story_adventure_screen.dart';
import '../services/engagement_content_service.dart';
import '../services/gamification_service.dart';
import '../services/listening_lab_service.dart';
import '../services/mini_game_service.dart';
import '../services/story_adventure_service.dart';
import '../screens/daily_learning_screen.dart';
import '../screens/diagnostic_assessment_screen.dart';
import '../screens/parent_dashboard_screen.dart';
import '../screens/student_profile_screen.dart';
import '../screens/writing_practice_screen.dart';
import '../services/daily_plan_service.dart';
import '../services/diagnostic_service.dart';
import '../services/learning_analytics_service.dart';
import '../services/student_profile_service.dart';
import '../services/writing_practice_service.dart';
import '../curriculum/curriculum_engine.dart';
import '../curriculum/curriculum_repository.dart';
import '../screens/dictionary_pack_manager_screen.dart';
import '../screens/learning_path_screen.dart';
import '../screens/offline_dictionary_screen.dart';
import '../screens/parent_control_screen.dart';
import '../services/dictionary_pack_service.dart';
import '../services/parent_control_service.dart';
import '../data/content_repository.dart';
import '../screens/progress_screen.dart';
import '../screens/story_screen.dart';
import '../screens/student_home_screen.dart';
import '../screens/tense_screen.dart';
import '../screens/voice_practice_screen.dart';
import '../services/progress_service.dart';
import '../services/teacher_orchestrator.dart';
import 'routes.dart';

class MewtionaryApp extends StatefulWidget {
  const MewtionaryApp({super.key});

  @override
  State<MewtionaryApp> createState() => _MewtionaryAppState();
}

class _MewtionaryAppState extends State<MewtionaryApp> {
  final teacher = TeacherOrchestrator();
  final progress = ProgressService();
  final repository = ContentRepository();
  final curriculumRepository = CurriculumRepository();
  final curriculumEngine = CurriculumEngine();
  final dictionaryPacks = DictionaryPackService();
  final parentControls = ParentControlService();
  final studentProfile = StudentProfileService();
  final diagnostic = DiagnosticService();
  final writingPractice = WritingPracticeService();
  final engagementContent = EngagementContentService();
  final gamification = GamificationService();
  final miniGames = MiniGameService();
  final listeningLab = ListeningLabService();
  final storyAdventures = StoryAdventureService();
  final tutorStudioContent = TutorStudioContentService();
  final conversationTutor = ConversationTutorService();
  final homeworkStudio = HomeworkStudioService();
  final smartRevision = SmartRevisionService();
  final examCoachContent = ExamCoachContentService();
  final pronunciationCoach = PronunciationCoachService();
  final mockExam = MockExamService();
  late final StudyPlannerService studyPlanner;
  late final CertificateService certificateService;
  late final ParentReportService parentReport;
  late final DailyPlanService dailyPlan;
  late final LearningAnalyticsService analytics;

  @override
  void initState() {
    super.initState();
    dailyPlan = DailyPlanService(
      repository: curriculumRepository,
      engine: curriculumEngine,
      parentControls: parentControls,
    );
    analytics = LearningAnalyticsService(
      repository: curriculumRepository,
      engine: curriculumEngine,
    );
    parentReport = ParentReportService(
      analytics: analytics,
      gamification: gamification,
      profile: studentProfile,
    );
    studyPlanner = StudyPlannerService(
      analytics: analytics,
    );
    certificateService = CertificateService(
      content: examCoachContent,
      gamification: gamification,
      profile: studentProfile,
    );
    teacher.initialise();
    progress.load();
    curriculumEngine.load();
    parentControls.load();
    studentProfile.load();
    gamification.load();
  }

  @override
  void dispose() {
    teacher.dispose();
    progress.dispose();
    curriculumEngine.dispose();
    parentControls.dispose();
    studentProfile.dispose();
    gamification.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mewtionary',
      debugShowCheckedModeBanner: false,
      theme: MewtionaryTheme.light,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => StudentHomeScreen(
              teacher: teacher,
              progress: progress,
            ),
        AppRoutes.dictionary: (_) => OfflineDictionaryScreen(
              teacher: teacher,
              progress: progress,
              service: dictionaryPacks,
            ),
        AppRoutes.tense: (_) => TenseScreen(
              teacher: teacher,
              progress: progress,
              repository: repository,
            ),
        AppRoutes.story: (_) => StoryScreen(
              teacher: teacher,
              progress: progress,
              repository: repository,
            ),
        AppRoutes.voice: (_) => VoicePracticeScreen(
              teacher: teacher,
              progress: progress,
            ),
        AppRoutes.progress: (_) => ProgressScreen(
              progress: progress,
            ),
        AppRoutes.learningPath: (_) => LearningPathScreen(
              teacher: teacher,
              engine: curriculumEngine,
              repository: curriculumRepository,
            ),
        AppRoutes.dictionaryPacks: (_) => DictionaryPackManagerScreen(
              service: dictionaryPacks,
            ),
        AppRoutes.parentControls: (_) => ParentControlScreen(
              service: parentControls,
            ),
        AppRoutes.dailyLearning: (_) => DailyLearningScreen(
              service: dailyPlan,
              profile: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.diagnostic: (_) => DiagnosticAssessmentScreen(
              service: diagnostic,
              profile: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.writingPractice: (_) => WritingPracticeScreen(
              service: writingPractice,
              profile: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.parentDashboard: (_) => ParentDashboardScreen(
              analytics: analytics,
              profile: studentProfile,
            ),
        AppRoutes.studentProfile: (_) => StudentProfileScreen(
              service: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.learningGames: (_) => LearningGamesScreen(
              content: engagementContent,
              games: miniGames,
              gamification: gamification,
              profile: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.listeningLab: (_) => ListeningLabScreen(
              content: engagementContent,
              listening: listeningLab,
              gamification: gamification,
              profile: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.storyAdventures: (_) => StoryAdventureScreen(
              content: engagementContent,
              adventures: storyAdventures,
              gamification: gamification,
              profile: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.rewards: (_) => RewardsScreen(
              gamification: gamification,
            ),
        AppRoutes.conversationLab: (_) => ConversationLabScreen(
              content: tutorStudioContent,
              tutor: conversationTutor,
              gamification: gamification,
              profile: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.homeworkStudio: (_) => HomeworkStudioScreen(
              content: tutorStudioContent,
              studio: homeworkStudio,
              profile: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.smartRevision: (_) => SmartRevisionScreen(
              content: tutorStudioContent,
              revision: smartRevision,
              analytics: analytics,
              gamification: gamification,
              profile: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.parentReport: (_) => ParentReportScreen(
              service: parentReport,
            ),
        AppRoutes.pronunciationCoach: (_) => PronunciationCoachScreen(
              content: examCoachContent,
              coach: pronunciationCoach,
              gamification: gamification,
              profile: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.mockExam: (_) => MockExamScreen(
              content: examCoachContent,
              exam: mockExam,
              gamification: gamification,
              profile: studentProfile,
              teacher: teacher,
            ),
        AppRoutes.studyPlanner: (_) => StudyPlannerScreen(
              service: studyPlanner,
              gamification: gamification,
            ),
        AppRoutes.certificateStudio: (_) => CertificateStudioScreen(
              service: certificateService,
            ),
      },
    );
  }
}
