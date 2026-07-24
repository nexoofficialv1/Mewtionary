import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../core/mewtionary_theme.dart';
import '../models/learning_models.dart';
import '../services/progress_service.dart';
import '../services/teacher_orchestrator.dart';
import '../widgets/common_widgets.dart';
import '../widgets/teacher_viewport.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({
    required this.teacher,
    required this.progress,
    super.key,
  });

  final TeacherOrchestrator teacher;
  final ProgressService progress;

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  LearningMode mode = LearningMode.class4To6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.teacher.welcome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mewtionary',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              'Learn English with your 3D Teacher',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.rewards,
            ),
            icon: const Icon(Icons.emoji_events_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TeacherViewport(teacher: widget.teacher),
          const SizedBox(height: 20),
          const SectionTitle(
            'তোমার Learning Level',
            subtitle: 'Level অনুযায়ী lesson ও Teacher-এর ভাষা বদলাবে',
          ),
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: LearningMode.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = LearningMode.values[index];
                return ChoiceChipButton(
                  label: item.title,
                  selected: item == mode,
                  onTap: () => setState(() => mode = item),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          ModuleCard(
            title: "Today's Adaptive Plan",
            subtitle: 'Profile, level, revision ও সময় অনুযায়ী daily tasks',
            icon: Icons.today_rounded,
            color: Colors.green,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.dailyLearning,
            ),
          ),
          ModuleCard(
            title: 'Class-wise Learning Path',
            subtitle: 'Early Learner থেকে Class 9 পর্যন্ত structured curriculum',
            icon: Icons.route_rounded,
            color: Colors.indigo,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.learningPath,
            ),
          ),
          ModuleCard(
            title: 'English–Bangla Dictionary',
            subtitle: 'Meaning, pronunciation, example ও Teacher explanation',
            icon: Icons.menu_book_rounded,
            color: MewtionaryTheme.teal,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.dictionary,
            ),
          ),
          ModuleCard(
            title: 'Tense & Grammar',
            subtitle: 'Board explanation, examples এবং interactive quiz',
            icon: Icons.auto_stories_rounded,
            color: MewtionaryTheme.navy,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.tense,
            ),
          ),
          ModuleCard(
            title: 'Animated Story',
            subtitle: 'Teacher বই পড়ে শোনাবে এবং প্রশ্ন করবে',
            icon: Icons.theater_comedy_rounded,
            color: MewtionaryTheme.coral,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.story,
            ),
          ),
          ModuleCard(
            title: 'Quick Voice Practice',
            subtitle: 'ছোট sentence repeat ও quick transcript feedback',
            icon: Icons.record_voice_over_rounded,
            color: Colors.deepPurple,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.voice,
            ),
          ),
          ModuleCard(
            title: 'Pronunciation Coach',
            subtitle: 'Sound focus, syllable chunk, minimal pair ও speech score',
            icon: Icons.graphic_eq_rounded,
            color: Colors.deepPurple,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.pronunciationCoach,
            ),
          ),
          ModuleCard(
            title: 'Mock Exam Centre',
            subtitle: 'Class-wise timed MCQ, fill blank ও writing practice',
            icon: Icons.fact_check_rounded,
            color: Colors.red,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.mockExam,
            ),
          ),
          ModuleCard(
            title: 'Weekly Study Planner',
            subtitle: 'Auto weekly plan, custom task ও completion tracking',
            icon: Icons.calendar_month_rounded,
            color: Colors.green,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.studyPlanner,
            ),
          ),
          ModuleCard(
            title: 'Certificate Studio',
            subtitle: 'Achievement অনুযায়ী printable learning certificate',
            icon: Icons.workspace_premium_rounded,
            color: Colors.amber,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.certificateStudio,
            ),
          ),
          ModuleCard(
            title: 'Conversation Lab',
            subtitle: 'School, shop, clinic ও interview guided dialogue',
            icon: Icons.forum_rounded,
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.conversationLab,
            ),
          ),
          ModuleCard(
            title: 'Homework Studio',
            subtitle: 'Sentence, paragraph, letter, notice ও report builder',
            icon: Icons.assignment_rounded,
            color: Colors.purple,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.homeworkStudio,
            ),
          ),
          ModuleCard(
            title: 'Smart Revision',
            subtitle: 'দুর্বল skill আগে রেখে adaptive revision quiz',
            icon: Icons.psychology_alt_rounded,
            color: Colors.lightGreen,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.smartRevision,
            ),
          ),
          ModuleCard(
            title: 'Parent Report Export',
            subtitle: 'Printable HTML, CSV ও text progress summary',
            icon: Icons.summarize_rounded,
            color: Colors.blueGrey,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.parentReport,
            ),
          ),
          ModuleCard(
            title: 'Learning Games',
            subtitle: 'Word Match, Spelling ও Sentence Builder',
            icon: Icons.sports_esports_rounded,
            color: Colors.green,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.learningGames,
            ),
          ),
          ModuleCard(
            title: 'Listening Lab',
            subtitle: 'Listen-and-choose ও English dictation practice',
            icon: Icons.headphones_rounded,
            color: Colors.deepOrange,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.listeningLab,
            ),
          ),
          ModuleCard(
            title: 'Story Adventures',
            subtitle: 'Vocabulary, comprehension ও reward সহ story reading',
            icon: Icons.auto_stories_rounded,
            color: Colors.redAccent,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.storyAdventures,
            ),
          ),
          ModuleCard(
            title: 'Rewards & Badges',
            subtitle: 'XP, coins, level, streak ও achievement cabinet',
            icon: Icons.workspace_premium_rounded,
            color: Colors.amber,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.rewards,
            ),
          ),
          ModuleCard(
            title: 'Placement Assessment',
            subtitle: 'শিশুর উপযুক্ত learning level নির্ধারণ করুন',
            icon: Icons.quiz_rounded,
            color: Colors.blueGrey,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.diagnostic,
            ),
          ),
          ModuleCard(
            title: 'Writing Practice',
            subtitle: 'Letter, word ও sentence tracing canvas',
            icon: Icons.draw_rounded,
            color: Colors.pink,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.writingPractice,
            ),
          ),
          ModuleCard(
            title: 'Parent Analytics',
            subtitle: 'Skill mastery, activity, revision ও progress summary',
            icon: Icons.insights_rounded,
            color: Colors.cyan,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.parentDashboard,
            ),
          ),
          ModuleCard(
            title: 'Student Profile',
            subtitle: 'Name, age এবং current learning level',
            icon: Icons.account_circle_rounded,
            color: Colors.teal,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.studentProfile,
            ),
          ),
          ModuleCard(
            title: 'Dictionary Data Packs',
            subtitle: 'Licensed offline pack install ও manage করুন',
            icon: Icons.storage_rounded,
            color: Colors.brown,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.dictionaryPacks,
            ),
          ),
          ModuleCard(
            title: 'Parent Controls',
            subtitle: 'সময়, voice, Bangla support ও low-motion settings',
            icon: Icons.family_restroom_rounded,
            color: Colors.orange,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.parentControls,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: widget.progress,
            builder: (context, _) {
              final value = widget.progress.progress;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 42,
                        color: MewtionaryTheme.amber,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'আজ পর্যন্ত ${value.stars} Stars অর্জন করেছ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
