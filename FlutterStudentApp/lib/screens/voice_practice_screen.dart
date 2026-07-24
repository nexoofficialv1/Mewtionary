import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/mewtionary_theme.dart';
import '../services/progress_service.dart';
import '../services/pronunciation_scoring_service.dart';
import '../services/learning_feedback_service.dart';
import '../widgets/learning_feedback_anchor.dart';

class VoicePracticeScreen extends StatefulWidget {
  const VoicePracticeScreen({
    required this.teacher,
    required this.progress,
    super.key,
  });

  final LearningFeedbackService teacher;
  final ProgressService progress;

  @override
  State<VoicePracticeScreen> createState() => _VoicePracticeScreenState();
}

class _VoicePracticeScreenState extends State<VoicePracticeScreen> {
  final speech = SpeechToText();
  final scoring = const PronunciationScoringService();

  final phrases = const [
    'Good morning, teacher.',
    'The flower is beautiful.',
    'She goes to school every day.',
    'Honesty is the best policy.',
  ];

  int phraseIndex = 0;
  bool ready = false;
  bool listening = false;
  String heard = '';
  double score = 0;

  String get target => phrases[phraseIndex];

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final available = await speech.initialize();
    if (!mounted) return;
    setState(() => ready = available);
  }

  Future<void> _start() async {
    if (!ready) return;
    await widget.teacher.listen();
    setState(() {
      heard = '';
      score = 0;
      listening = true;
    });

    await speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => heard = result.recognizedWords);
        if (result.finalResult) _evaluate(result.recognizedWords);
      },
      localeId: 'en_US',
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> _stop() async {
    await speech.stop();
    if (!mounted) return;
    setState(() => listening = false);
    if (heard.isNotEmpty) await _evaluate(heard);
  }

  Future<void> _evaluate(String transcript) async {
    final result = scoring.score(
      expected: target,
      heard: transcript,
    );
    final value = result.total;
    final correct = value >= .72;
    if (!mounted) return;
    setState(() {
      score = value;
      listening = false;
    });

    await widget.progress.addVoiceAttempt(correct: correct);

    if (correct) {
      await widget.teacher.praise(
        'Excellent! তোমার score ${(value * 100).round()} percent.',
      );
    } else {
      final missing = result.missingWords.isEmpty
          ? ''
          : ' Missing words: ${result.missingWords.join(', ')}.';
      await widget.teacher.correct(
        'ধীরে বলো: $target.$missing',
      );
    }
  }


  void _nextPhrase() {
    setState(() {
      phraseIndex = (phraseIndex + 1) % phrases.length;
      heard = '';
      score = 0;
    });
    widget.teacher.act(
      state: LearningFeedbackState.speaking,
      message: 'Repeat after me: $target',
    );
  }

  @override
  void dispose() {
    speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Practice')),
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
                  const Text(
                    'Repeat after Teacher',
                    style: TextStyle(
                      color: MewtionaryTheme.teal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    target,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      height: 1.35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => widget.teacher.act(
                      state: LearningFeedbackState.speaking,
                      message: 'Repeat after me: $target',
                    ),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Teacher বলবে'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: !ready
                        ? null
                        : listening
                            ? _stop
                            : _start,
                    icon: Icon(
                      listening ? Icons.stop_rounded : Icons.mic_rounded,
                    ),
                    label: Text(
                      listening ? 'Stop Listening' : 'এখন তুমি বলো',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F0E8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      heard.isEmpty
                          ? 'তোমার বলা কথা এখানে দেখা যাবে।'
                          : heard,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: heard.isEmpty
                            ? Colors.black45
                            : MewtionaryTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (score > 0) ...[
                    const SizedBox(height: 14),
                    LinearProgressIndicator(
                      value: score,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pronunciation score: ${(score * 100).round()}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _nextPhrase,
                    icon: const Icon(Icons.skip_next_rounded),
                    label: const Text('Next sentence'),
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
