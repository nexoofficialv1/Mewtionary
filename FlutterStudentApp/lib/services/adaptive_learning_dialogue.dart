import 'dart:math';


import '../models/curriculum_models.dart';
import 'learning_feedback_service.dart';

class AdaptiveLearningDialogue {
  AdaptiveLearningDialogue(this.teacher);

  final LearningFeedbackService teacher;
  final Random _random = Random();

  Future<void> introduce(CurriculumLesson lesson) async {
    final lines = [
      'আজ আমরা ${lesson.banglaTitle} শিখব।',
      'চলো, আজকের lesson হলো ${lesson.title}।',
      'আজ ${lesson.skill.label} practice করব।',
    ];
    await teacher.act(
      state: LearningFeedbackState.welcome,
      message: lines[_random.nextInt(lines.length)],
      prop: lesson.skill == CurriculumSkill.story
          ? LearningFeedbackContext.book
          : LearningFeedbackContext.none,
    );
  }

  Future<void> react({
    required double score,
    required int attempts,
    String? hint,
  }) async {
    if (score >= .9) {
      await teacher.act(
        state: LearningFeedbackState.dancing,
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
        state: LearningFeedbackState.pointing,
        message: hint ??
            'আমি rule-টি বোর্ডে সহজ করে দেখাচ্ছি।',
        prop: LearningFeedbackContext.pointer,
      );
    }
  }
}
