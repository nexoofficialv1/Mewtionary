import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../models/adaptive_learning_models.dart';
import '../services/student_profile_service.dart';
import '../services/learning_feedback_service.dart';
import '../services/writing_practice_service.dart';
import '../widgets/learning_feedback_anchor.dart';

class WritingPracticeScreen extends StatefulWidget {
  const WritingPracticeScreen({
    required this.service,
    required this.profile,
    required this.teacher,
    super.key,
  });

  final WritingPracticeService service;
  final StudentProfileService profile;
  final LearningFeedbackService teacher;

  @override
  State<WritingPracticeScreen> createState() =>
      _WritingPracticeScreenState();
}

class _WritingPracticeScreenState
    extends State<WritingPracticeScreen> {
  List<WritingPrompt> prompts = const [];
  int promptIndex = 0;
  final strokes = <List<Offset>>[];
  int selfScore = 4;
  bool loading = true;

  WritingPrompt get prompt => prompts[promptIndex];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.profile.load();
    final data = await widget.service.loadPrompts(
      widget.profile.profile.level,
    );
    if (!mounted) return;
    setState(() {
      prompts = data;
      loading = false;
    });
    await _speakPrompt();
  }

  Future<void> _speakPrompt() async {
    if (prompts.isEmpty) return;
    await widget.teacher.act(
      state: LearningFeedbackState.writingBoard,
      message: prompt.instruction,
      prop: LearningFeedbackContext.chalk,
    );
  }

  void _start(DragStartDetails details) {
    setState(() {
      strokes.add([details.localPosition]);
    });
  }

  void _update(DragUpdateDetails details) {
    if (strokes.isEmpty) return;
    setState(() {
      strokes.last.add(details.localPosition);
    });
  }

  void _undo() {
    if (strokes.isEmpty) return;
    setState(() => strokes.removeLast());
  }

  void _clear() {
    setState(strokes.clear);
  }

  Future<void> _save() async {
    await widget.service.saveAttempt(
      prompt: prompt,
      strokeCount: strokes.length,
      selfScore: selfScore,
    );
    await widget.teacher.praise(
      'Writing practice complete! তোমার চেষ্টা save হয়েছে।',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Writing attempt saved'),
      ),
    );
  }

  void _next() {
    setState(() {
      promptIndex = (promptIndex + 1) % prompts.length;
      strokes.clear();
      selfScore = 4;
    });
    _speakPrompt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Writing Practice')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                LearningFeedbackAnchor(teacher: widget.teacher, height: 245),
                const SizedBox(height: 12),
                Card(
                  color: const Color(0xFFFFF1C7),
                  child: ListTile(
                    title: Text(
                      prompt.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(prompt.instruction),
                    trailing: IconButton(
                      onPressed: _speakPrompt,
                      icon: const Icon(Icons.volume_up_rounded),
                    ),
                  ),
                ),
                SizedBox(
                  height: 330,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(color: Colors.white),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              prompt.guideText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 58,
                                color: Color(0x1A17395C),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: GestureDetector(
                            onPanStart: _start,
                            onPanUpdate: _update,
                            child: CustomPaint(
                              painter: _StrokePainter(strokes),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _undo,
                        icon: const Icon(Icons.undo_rounded),
                        label: const Text('Undo'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _clear,
                        icon: const Icon(Icons.delete_sweep_rounded),
                        label: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'নিজের লেখাকে score দাও: $selfScore/5',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Slider(
                          value: selfScore.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: '$selfScore',
                          onChanged: (value) {
                            setState(() => selfScore = value.round());
                          },
                        ),
                        const Text(
                          'এই version stroke ও practice record save করে। '
                          'এটি handwriting OCR বা automatic handwriting grading দাবি করে না।',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: strokes.isEmpty ? null : _save,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Finish Practice'),
                ),
                TextButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text('Next Prompt'),
                ),
              ],
            ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  const _StrokePainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MewtionaryTheme.navy
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}
