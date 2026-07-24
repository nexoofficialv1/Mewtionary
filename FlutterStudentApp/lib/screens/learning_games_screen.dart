import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../models/engagement_models.dart';
import '../services/engagement_content_service.dart';
import '../services/gamification_service.dart';
import '../services/mini_game_service.dart';
import '../services/student_profile_service.dart';
import '../services/learning_feedback_service.dart';
import '../widgets/learning_feedback_anchor.dart';

class LearningGamesScreen extends StatefulWidget {
  const LearningGamesScreen({
    required this.content,
    required this.games,
    required this.gamification,
    required this.profile,
    required this.teacher,
    super.key,
  });

  final EngagementContentService content;
  final MiniGameService games;
  final GamificationService gamification;
  final StudentProfileService profile;
  final LearningFeedbackService teacher;

  @override
  State<LearningGamesScreen> createState() =>
      _LearningGamesScreenState();
}

class _LearningGamesScreenState extends State<LearningGamesScreen> {
  List<MiniGameChallenge> challenges = const [];
  int index = 0;
  int attempts = 0;
  bool solved = false;
  bool loading = true;
  final selectedIndices = <int>[];

  MiniGameChallenge get challenge => challenges[index];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.profile.load();
    await widget.gamification.load();
    final data = await widget.content.loadGames(
      widget.profile.profile.level,
    );
    if (!mounted) return;
    setState(() {
      challenges = data;
      loading = false;
    });
    await _introduce();
  }

  Future<void> _introduce() async {
    if (challenges.isEmpty) return;
    await widget.teacher.act(
      state: widget.teacher.status.state,
      message:
          '${challenge.type.banglaTitle}। ${challenge.prompt}',
    );
  }

  Future<void> _selectWordMatch(String option) async {
    if (solved) return;
    attempts++;
    final correct = widget.games.checkWordMatch(
      challenge,
      option,
    );
    await _finishAttempt(correct);
  }

  void _selectToken(int optionIndex) {
    if (solved || selectedIndices.contains(optionIndex)) return;
    setState(() => selectedIndices.add(optionIndex));
  }

  void _removeLast() {
    if (solved || selectedIndices.isEmpty) return;
    setState(() => selectedIndices.removeLast());
  }

  Future<void> _checkBuilder() async {
    if (solved || selectedIndices.isEmpty) return;
    attempts++;
    final values = [
      for (final optionIndex in selectedIndices)
        challenge.options[optionIndex],
    ];

    final correct = challenge.type == MiniGameType.spelling
        ? widget.games.checkSpelling(challenge, values)
        : widget.games.checkSentence(challenge, values);
    await _finishAttempt(correct);
  }

  Future<void> _finishAttempt(bool correct) async {
    await widget.games.saveAttempt(
      challenge: challenge,
      correct: correct,
      attempts: attempts,
    );

    if (correct) {
      final awarded = await widget.gamification.award(
        sourceType: 'game',
        sourceId: challenge.id,
        xp: challenge.xp,
        coins: challenge.coins,
      );
      if (!mounted) return;
      setState(() => solved = true);
      await widget.teacher.praise(
        awarded
            ? 'Game complete! ${challenge.xp} XP এবং '
                '${challenge.coins} coins পেয়েছ।'
            : 'সঠিক উত্তর! এই challenge-এর reward আগে পাওয়া হয়েছে।',
      );
    } else {
      await widget.teacher.correct(challenge.hint);
      if (!mounted) return;
      setState(selectedIndices.clear);
    }
  }

  Future<void> _next() async {
    if (index >= challenges.length - 1) {
      setState(() {
        index = 0;
        attempts = 0;
        solved = false;
        selectedIndices.clear();
      });
    } else {
      setState(() {
        index++;
        attempts = 0;
        solved = false;
        selectedIndices.clear();
      });
    }
    await _introduce();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (challenges.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No games available.')),
      );
    }

    final selectedText = challenge.type == MiniGameType.spelling
        ? [
            for (final i in selectedIndices) challenge.options[i],
          ].join()
        : [
            for (final i in selectedIndices) challenge.options[i],
          ].join(' ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Games'),
        actions: [
          AnimatedBuilder(
            animation: widget.gamification,
            builder: (_, __) => Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Text(
                  'Lv ${widget.gamification.wallet.level} · '
                  '🪙 ${widget.gamification.wallet.coins}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LearningFeedbackAnchor(teacher: widget.teacher, height: 255),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: (index + 1) / challenges.length,
            minHeight: 9,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 10),
          Card(
            color: const Color(0xFFFFF1C7),
            child: Padding(
              padding: const EdgeInsets.all(19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    challenge.type.title,
                    style: const TextStyle(
                      color: MewtionaryTheme.teal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    challenge.prompt,
                    style: const TextStyle(
                      fontSize: 22,
                      color: MewtionaryTheme.navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '+${challenge.xp} XP · '
                    '+${challenge.coins} coins',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (challenge.type == MiniGameType.wordMatch)
            for (final option in challenge.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: OutlinedButton(
                  onPressed: solved
                      ? null
                      : () => _selectWordMatch(option),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'তোমার উত্তর',
                      style: TextStyle(
                        color: MewtionaryTheme.teal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints:
                          const BoxConstraints(minHeight: 58),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7F8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        selectedText.isEmpty
                            ? 'নিচের token-গুলো tap করো'
                            : selectedText,
                        style: const TextStyle(
                          fontSize: 21,
                          color: MewtionaryTheme.navy,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0;
                            i < challenge.options.length;
                            i++)
                          ChoiceChip(
                            label: Text(challenge.options[i]),
                            selected: selectedIndices.contains(i),
                            onSelected: selectedIndices.contains(i)
                                ? null
                                : (_) => _selectToken(i),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _removeLast,
                            icon: const Icon(Icons.undo_rounded),
                            label: const Text('Undo'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: solved ? null : _checkBuilder,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Check'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (solved)
            FilledButton.icon(
              onPressed: _next,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next Game'),
            ),
        ],
      ),
    );
  }
}
