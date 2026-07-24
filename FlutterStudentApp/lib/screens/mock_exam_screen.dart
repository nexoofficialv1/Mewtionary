import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mewtionary_teacher3d_bridge/mewtionary_teacher3d_bridge.dart';

import '../core/mewtionary_theme.dart';
import '../models/curriculum_models.dart';
import '../models/exam_coach_models.dart';
import '../services/exam_coach_content_service.dart';
import '../services/gamification_service.dart';
import '../services/mock_exam_service.dart';
import '../services/student_profile_service.dart';
import '../services/teacher_orchestrator.dart';
import '../widgets/teacher_viewport.dart';

class MockExamScreen extends StatefulWidget {
  const MockExamScreen({
    required this.content,
    required this.exam,
    required this.gamification,
    required this.profile,
    required this.teacher,
    super.key,
  });

  final ExamCoachContentService content;
  final MockExamService exam;
  final GamificationService gamification;
  final StudentProfileService profile;
  final TeacherOrchestrator teacher;

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  List<MockExamPaper> papers = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.profile.load();
    await widget.gamification.load();
    final data = await widget.content.loadExams(
      widget.profile.profile.level,
    );
    if (!mounted) return;
    setState(() {
      papers = data;
      loading = false;
    });
  }

  Future<void> _open(MockExamPaper paper) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MockExamPlayerScreen(
          paper: paper,
          service: widget.exam,
          gamification: widget.gamification,
          teacher: widget.teacher,
        ),
      ),
    );
    await widget.gamification.load();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Exam Centre')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TeacherViewport(
                  teacher: widget.teacher,
                  height: 255,
                ),
                const SizedBox(height: 14),
                const Card(
                  color: Color(0xFFFFF1C7),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: MewtionaryTheme.amber,
                      child: Icon(
                        Icons.timer_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Class-wise timed practice',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      'MCQ, fill blank, rearrange ও short-answer question',
                    ),
                  ),
                ),
                for (final paper in papers)
                  Card(
                    child: ListTile(
                      onTap: () => _open(paper),
                      leading: const CircleAvatar(
                        child: Icon(Icons.fact_check_rounded),
                      ),
                      title: Text(
                        paper.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        '${paper.banglaTitle}\n'
                        '${paper.durationMinutes} minutes · '
                        '${paper.totalMarks} marks',
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        '+${paper.xp} XP',
                        style: const TextStyle(
                          color: MewtionaryTheme.teal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Short-answer checking sample key ideas ও basic sentence '
                      'rules ব্যবহার করে। Final school assessment হিসেবে '
                      'ব্যবহারের আগে শিক্ষক review প্রয়োজন।',
                      style: TextStyle(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class MockExamPlayerScreen extends StatefulWidget {
  const MockExamPlayerScreen({
    required this.paper,
    required this.service,
    required this.gamification,
    required this.teacher,
    super.key,
  });

  final MockExamPaper paper;
  final MockExamService service;
  final GamificationService gamification;
  final TeacherOrchestrator teacher;

  @override
  State<MockExamPlayerScreen> createState() =>
      _MockExamPlayerScreenState();
}

class _MockExamPlayerScreenState
    extends State<MockExamPlayerScreen> {
  final answers = <String, String>{};
  final controllers = <String, TextEditingController>{};

  Timer? timer;
  late int secondsLeft;
  int index = 0;
  bool started = false;
  bool submitted = false;
  MockExamResult? result;

  MockExamQuestion get question => widget.paper.questions[index];

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.paper.durationMinutes * 60;
    for (final question in widget.paper.questions) {
      if (question.type != ExamQuestionType.mcq) {
        controllers[question.id] = TextEditingController();
      }
    }
  }

  Future<void> _start() async {
    setState(() => started = true);
    timer = Timer.periodic(const Duration(seconds: 1), (value) {
      if (!mounted) return;
      if (secondsLeft <= 1) {
        value.cancel();
        setState(() => secondsLeft = 0);
        _submit();
      } else {
        setState(() => secondsLeft--);
      }
    });
    await widget.teacher.act(
      state: Teacher3DState.pointing,
      message: 'Exam started. Read carefully and manage your time.',
      prop: Teacher3DProp.pointer,
    );
  }

  void _setMcq(String value) {
    setState(() => answers[question.id] = value);
  }

  void _saveTextAnswer() {
    final controller = controllers[question.id];
    if (controller != null) {
      answers[question.id] = controller.text.trim();
    }
  }

  void _next() {
    _saveTextAnswer();
    if (index < widget.paper.questions.length - 1) {
      setState(() => index++);
    }
  }

  void _previous() {
    _saveTextAnswer();
    if (index > 0) {
      setState(() => index--);
    }
  }

  Future<void> _submit() async {
    if (submitted) return;
    timer?.cancel();
    for (final entry in controllers.entries) {
      answers[entry.key] = entry.value.text.trim();
    }

    final value = widget.service.evaluate(
      paper: widget.paper,
      answers: answers,
    );
    await widget.service.save(
      paper: widget.paper,
      result: value,
      answers: answers,
    );

    final passed = value.percentage >= .4;
    final date = DateTime.now();
    final rewardId =
        '${widget.paper.id}_${date.year}_${date.month}_${date.day}';
    if (passed) {
      await widget.gamification.award(
        sourceType: 'mock_exam',
        sourceId: rewardId,
        xp: widget.paper.xp,
        coins: widget.paper.coins,
      );
    }

    if (!mounted) return;
    setState(() {
      result = value;
      submitted = true;
    });

    if (passed) {
      await widget.teacher.praise(
        'Exam passed! Score ${(value.percentage * 100).round()} percent.',
      );
    } else {
      await widget.teacher.correct(
        'Practice আরও দরকার। Answer review করে আবার চেষ্টা করো।',
      );
    }
  }

  String get _time {
    final minutes = secondsLeft ~/ 60;
    final seconds = secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paper.title),
        actions: [
          if (started && !submitted)
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Center(
                child: Text(
                  _time,
                  style: TextStyle(
                    color: secondsLeft < 60
                        ? Colors.redAccent
                        : Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: !started
          ? _instructions()
          : submitted
              ? _result()
              : _question(),
    );
  }

  Widget _instructions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TeacherViewport(
          teacher: widget.teacher,
          height: 255,
        ),
        const SizedBox(height: 14),
        Card(
          color: const Color(0xFFFFF1C7),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 60,
                  color: MewtionaryTheme.teal,
                ),
                Text(
                  widget.paper.banglaTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    color: MewtionaryTheme.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${widget.paper.questions.length} questions · '
                  '${widget.paper.totalMarks} marks · '
                  '${widget.paper.durationMinutes} minutes',
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
                  'Instructions',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                for (final item in widget.paper.instructions)
                  Text('• $item'),
              ],
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start Exam'),
        ),
      ],
    );
  }

  Widget _question() {
    final selected = answers[question.id];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(
          value: (index + 1) / widget.paper.questions.length,
          minHeight: 10,
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
                  '${question.skill.label} · '
                  '${question.marks} mark(s) · '
                  '${index + 1}/${widget.paper.questions.length}',
                  style: const TextStyle(
                    color: MewtionaryTheme.teal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  question.prompt,
                  style: const TextStyle(
                    fontSize: 21,
                    height: 1.4,
                    color: MewtionaryTheme.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (question.type == ExamQuestionType.mcq)
          for (final option in question.options)
            RadioListTile<String>(
              value: option,
              groupValue: selected,
              onChanged: (value) {
                if (value != null) _setMcq(value);
              },
              title: Text(
                option,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
        else
          TextField(
            controller: controllers[question.id],
            minLines:
                question.type == ExamQuestionType.shortAnswer ? 4 : 2,
            maxLines:
                question.type == ExamQuestionType.shortAnswer ? 7 : 3,
            decoration: InputDecoration(
              labelText: switch (question.type) {
                ExamQuestionType.fillBlank => 'Fill the blank',
                ExamQuestionType.rearrange => 'Write the sentence',
                ExamQuestionType.shortAnswer => 'Write your answer',
                ExamQuestionType.mcq => 'Answer',
              },
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: index == 0 ? null : _previous,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed:
                    index == widget.paper.questions.length - 1
                        ? _submit
                        : _next,
                icon: Icon(
                  index == widget.paper.questions.length - 1
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                ),
                label: Text(
                  index == widget.paper.questions.length - 1
                      ? 'Submit'
                      : 'Next',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _result() {
    final value = result!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TeacherViewport(
          teacher: widget.teacher,
          height: 245,
        ),
        const SizedBox(height: 14),
        Card(
          color: value.percentage >= .4
              ? const Color(0xFFDFF4E2)
              : const Color(0xFFFFE7D8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  value.percentage >= .4
                      ? Icons.emoji_events_rounded
                      : Icons.menu_book_rounded,
                  size: 65,
                  color: value.percentage >= .4
                      ? Colors.green
                      : Colors.orange,
                ),
                Text(
                  '${(value.percentage * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 42,
                    color: MewtionaryTheme.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${value.earnedMarks}/${value.totalMarks} marks · '
                  '${value.correctAnswers}/${value.totalQuestions} correct',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        for (final entry in value.skillScores.entries)
          Card(
            child: ListTile(
              title: Text(entry.key.label),
              trailing: Text(
                '${(entry.value * 100).round()}%',
                style: const TextStyle(
                  color: MewtionaryTheme.teal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Answer Review',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: MewtionaryTheme.navy,
                fontWeight: FontWeight.w900,
              ),
        ),
        for (final item in widget.paper.questions)
          Card(
            child: ExpansionTile(
              title: Text(item.prompt),
              subtitle: Text(
                'Your answer: ${answers[item.id]?.isEmpty ?? true ? "Not answered" : answers[item.id]}',
              ),
              trailing: Icon(
                widget.service.isCorrect(
                  question: item,
                  answer: answers[item.id] ?? '',
                )
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: widget.service.isCorrect(
                  question: item,
                  answer: answers[item.id] ?? '',
                )
                    ? Colors.green
                    : Colors.redAccent,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Expected: ${item.answer}\n'
                      '${item.explanation}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Exam Centre'),
        ),
      ],
    );
  }
}
