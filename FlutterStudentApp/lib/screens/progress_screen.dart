import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../services/progress_service.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    required this.progress,
    super.key,
  });

  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Progress')),
      body: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final value = progress.progress;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: const Color(0xFFFFF1C7),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: MewtionaryTheme.amber,
                        size: 72,
                      ),
                      Text(
                        '${value.stars} Stars',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: MewtionaryTheme.navy,
                                ),
                      ),
                      const Text('Learning keeps making you stronger!'),
                    ],
                  ),
                ),
              ),
              _ProgressTile(
                icon: Icons.menu_book_rounded,
                title: 'Dictionary Words',
                value: value.dictionaryWords,
                color: MewtionaryTheme.teal,
              ),
              _ProgressTile(
                icon: Icons.auto_stories_rounded,
                title: 'Grammar Lessons',
                value: value.grammarLessons,
                color: MewtionaryTheme.navy,
              ),
              _ProgressTile(
                icon: Icons.theater_comedy_rounded,
                title: 'Stories Completed',
                value: value.stories,
                color: MewtionaryTheme.coral,
              ),
              _ProgressTile(
                icon: Icons.record_voice_over_rounded,
                title: 'Voice Attempts',
                value: value.voiceAttempts,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: progress.reset,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset Demo Progress'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        trailing: Text(
          '$value',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}
