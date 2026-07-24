import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../models/engagement_models.dart';
import '../services/engagement_content_service.dart';
import '../services/gamification_service.dart';
import '../services/story_adventure_service.dart';
import '../services/student_profile_service.dart';
import '../services/learning_feedback_service.dart';
import '../widgets/learning_feedback_anchor.dart';

class StoryAdventureScreen extends StatefulWidget {
  const StoryAdventureScreen({
    required this.content,
    required this.adventures,
    required this.gamification,
    required this.profile,
    required this.teacher,
    super.key,
  });

  final EngagementContentService content;
  final StoryAdventureService adventures;
  final GamificationService gamification;
  final StudentProfileService profile;
  final LearningFeedbackService teacher;

  @override
  State<StoryAdventureScreen> createState() =>
      _StoryAdventureScreenState();
}

class _StoryAdventureScreenState
    extends State<StoryAdventureScreen> {
  List<StoryAdventure> stories = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.profile.load();
    await widget.gamification.load();
    final data = await widget.content.loadAdventures(
      widget.profile.profile.level,
    );
    if (!mounted) return;
    setState(() {
      stories = data;
      loading = false;
    });
  }

  Future<void> _open(StoryAdventure story) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => StoryAdventurePlayerScreen(
          story: story,
          service: widget.adventures,
          gamification: widget.gamification,
          teacher: widget.teacher,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Story Adventures')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                LearningFeedbackAnchor(
                  teacher: widget.teacher,
                  height: 260,
                ),
                const SizedBox(height: 14),
                const Card(
                  color: Color(0xFFFFF1C7),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: MewtionaryTheme.amber,
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Read, listen and answer',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      'Vocabulary ও comprehension সহ interactive story',
                    ),
                  ),
                ),
                for (final story in stories)
                  Card(
                    child: ListTile(
                      onTap: () => _open(story),
                      leading: const CircleAvatar(
                        child: Icon(Icons.menu_book_rounded),
                      ),
                      title: Text(
                        story.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        '${story.banglaTitle}\n${story.summary}',
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        '+${story.xp} XP',
                        style: const TextStyle(
                          color: MewtionaryTheme.teal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class StoryAdventurePlayerScreen extends StatefulWidget {
  const StoryAdventurePlayerScreen({
    required this.story,
    required this.service,
    required this.gamification,
    required this.teacher,
    super.key,
  });

  final StoryAdventure story;
  final StoryAdventureService service;
  final GamificationService gamification;
  final LearningFeedbackService teacher;

  @override
  State<StoryAdventurePlayerScreen> createState() =>
      _StoryAdventurePlayerScreenState();
}

class _StoryAdventurePlayerScreenState
    extends State<StoryAdventurePlayerScreen> {
  int pageIndex = 0;
  int questionIndex = 0;
  int correctAnswers = 0;
  bool quizMode = false;
  bool answered = false;
  bool completed = false;

  AdventurePage get page => widget.story.pages[pageIndex];
  AdventureQuestion get question =>
      widget.story.questions[questionIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _read());
  }

  Future<void> _read() async {
    await widget.teacher.readStory(
      english: page.english,
      bangla: page.bangla,
      state: page.teacherState,
    );
    await widget.service.savePage(
      story: widget.story,
      pageIndex: pageIndex,
    );
  }

  Future<void> _nextPage() async {
    if (pageIndex < widget.story.pages.length - 1) {
      setState(() => pageIndex++);
      await _read();
    } else {
      setState(() => quizMode = true);
      await widget.teacher.act(
        state: LearningFeedbackState.pointing,
        message: 'এখন গল্পটি বুঝেছ কি না দেখি।',
        prop: LearningFeedbackContext.pointer,
      );
    }
  }

  Future<void> _answer(int index) async {
    if (answered || completed) return;
    final correct = index == question.correctIndex;
    if (correct) {
      correctAnswers++;
      await widget.teacher.praise('সঠিক! গল্পটি ভালো বুঝেছ।');
    } else {
      await widget.teacher.correct(question.hint);
    }
    if (!mounted) return;
    setState(() => answered = true);
  }

  Future<void> _nextQuestion() async {
    if (questionIndex < widget.story.questions.length - 1) {
      setState(() {
        questionIndex++;
        answered = false;
      });
      return;
    }

    await widget.service.complete(
      story: widget.story,
      correctAnswers: correctAnswers,
    );
    final awarded = await widget.gamification.award(
      sourceType: 'story',
      sourceId: widget.story.id,
      xp: widget.story.xp,
      coins: widget.story.coins,
    );
    if (!mounted) return;
    setState(() => completed = true);
    await widget.teacher.praise(
      awarded
          ? 'Story complete! ${widget.story.xp} XP এবং '
              '${widget.story.coins} coins পেয়েছ।'
          : 'গল্পটি আবার শেষ করেছ। খুব ভালো!',
    );
  }

  Future<void> _explainWord(AdventureVocabulary item) async {
    await widget.teacher.explainDictionary(
      word: item.word,
      meaning: item.bangla,
      example: 'This word appears in the story.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.story.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LearningFeedbackAnchor(
            teacher: widget.teacher,
            height: 260,
          ),
          const SizedBox(height: 14),
          if (!quizMode)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${pageIndex + 1}/${widget.story.pages.length}',
                      style: const TextStyle(
                        color: MewtionaryTheme.teal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      page.english,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.4,
                        color: MewtionaryTheme.navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      page.bangla,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _read,
                            icon: const Icon(
                              Icons.volume_up_rounded,
                            ),
                            label: const Text('Read Again'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _nextPage,
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                            ),
                            label: Text(
                              pageIndex ==
                                      widget.story.pages.length - 1
                                  ? 'Questions'
                                  : 'Next Page',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else if (!completed)
            Card(
              color: const Color(0xFFFFF1C7),
              child: Padding(
                padding: const EdgeInsets.all(19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Question ${questionIndex + 1}/'
                      '${widget.story.questions.length}',
                      style: const TextStyle(
                        color: MewtionaryTheme.teal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0;
                        i < question.options.length;
                        i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          onPressed:
                              answered ? null : () => _answer(i),
                          child: Text(question.options[i]),
                        ),
                      ),
                    if (answered)
                      FilledButton(
                        onPressed: _nextQuestion,
                        child: Text(
                          questionIndex ==
                                  widget.story.questions.length - 1
                              ? 'Finish Story'
                              : 'Next Question',
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            Card(
              color: const Color(0xFFDFF4E2),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 60,
                      color: Colors.green,
                    ),
                    const Text(
                      'Story Complete',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Correct answers: $correctAnswers/'
                      '${widget.story.questions.length}',
                    ),
                    const Divider(height: 24),
                    Text(
                      'Moral: ${widget.story.moral}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Story Vocabulary',
                    style: TextStyle(
                      color: MewtionaryTheme.navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in widget.story.vocabulary)
                        ActionChip(
                          onPressed: () => _explainWord(item),
                          avatar: const Icon(
                            Icons.volume_up_rounded,
                            size: 17,
                          ),
                          label: Text(
                            '${item.word} — ${item.bangla}',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
