import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../data/content_repository.dart';
import '../models/learning_models.dart';
import '../services/progress_service.dart';
import '../services/learning_feedback_service.dart';
import '../widgets/learning_feedback_anchor.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({
    required this.teacher,
    required this.progress,
    required this.repository,
    super.key,
  });

  final LearningFeedbackService teacher;
  final ProgressService progress;
  final ContentRepository repository;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  List<StoryLesson> stories = const [];
  int storyIndex = 0;
  int pageIndex = 0;

  StoryLesson get story => stories[storyIndex];
  StoryPage get page => story.pages[pageIndex];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.repository.loadStories();
    if (!mounted) return;
    setState(() => stories = data);
    await _read();
  }

  Future<void> _read() async {
    if (stories.isEmpty) return;
    await widget.teacher.readStory(
      english: page.english,
      bangla: page.bangla,
      state: page.teacherState,
    );
  }

  Future<void> _next() async {
    if (pageIndex < story.pages.length - 1) {
      setState(() => pageIndex++);
      await _read();
      return;
    }

    await widget.progress.completeStory();
    await widget.teacher.praise(
      'চমৎকার! পুরো গল্পটি শেষ হয়েছে। Moral: ${story.moral}',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Animated Story')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LearningFeedbackAnchor(
            teacher: widget.teacher,
            height: 300,
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: MewtionaryTheme.navy,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            Text(
                              story.banglaTitle,
                              style: const TextStyle(
                                color: MewtionaryTheme.teal,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${pageIndex + 1}/${story.pages.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 26),
                  Text(
                    page.english,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.4,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    page.bangla,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _read,
                          icon: const Icon(Icons.volume_up_rounded),
                          label: const Text('Read Again'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _next,
                          icon: Icon(
                            pageIndex == story.pages.length - 1
                                ? Icons.emoji_events_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                          label: Text(
                            pageIndex == story.pages.length - 1
                                ? 'Finish'
                                : 'Next Page',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (pageIndex == story.pages.length - 1)
            Card(
              color: const Color(0xFFFFF1C7),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Moral',
                      style: TextStyle(
                        color: MewtionaryTheme.teal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      story.moral,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
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
