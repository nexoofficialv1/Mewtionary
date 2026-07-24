import 'dart:math';

import 'package:mewtionary_teacher3d_bridge/mewtionary_teacher3d_bridge.dart';

import '../models/curriculum_models.dart';
import 'teacher_orchestrator.dart';

class AdaptiveTeacherDialogue {
  AdaptiveTeacherDialogue(this.teacher);

  final TeacherOrchestrator teacher;
  final Random _random = Random();

  Future<void> introduce(CurriculumLesson lesson) async {
    final lines = [
      'আজ আমরা ${lesson.banglaTitle} শিখব।',
      'চলো, আজকের lesson হলো ${lesson.title}।',
      'আজ ${lesson.skill.label} practice করব।',
    ];
    await teacher.act(
      state: Teacher3DState.welcome,
      message: lines[_random.nextInt(lines.length)],
      prop: lesson.skill == CurriculumSkill.story
          ? Teacher3DProp.book
          : Teacher3DProp.none,
    );
  }

  Future<void> react({
    required double score,
    required int attempts,
    String? hint,
  }) async {
    if (score >= .9) {
      await teacher.act(
        state: Teacher3DState.dancing,
        message: 'অসাধারণ! একদম নিখুঁত উত্তর।',
        duration: 2.5,
      );
    } else if (score >= .7) {
      await teacher.praise(
        'খুব ভালো! আর একটু practice করলে perfect হবে।',
      );
    } else if (attempts <= 1) {
      await teacher.correct(
        hint ?? 'চলো example দেখে আবার চেষ্টা করি।',
      );
    } else {
      await teacher.act(
        state: Teacher3DState.pointing,
        message: hint ??
            'আমি rule-টি বোর্ডে সহজ করে দেখাচ্ছি।',
        prop: Teacher3DProp.pointer,
      );
    }
  }
}
