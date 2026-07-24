import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/mewtionary_database.dart';
import '../models/curriculum_models.dart';

class CurriculumEngine extends ChangeNotifier {
  CurriculumEngine({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;
  final Map<String, LessonProgressRecord> _progress = {};

  Map<String, LessonProgressRecord> get progress =>
      Map.unmodifiable(_progress);

  Future<void> load() async {
    _progress
      ..clear()
      ..addAll(await _database.loadProgress());
    notifyListeners();
  }

  LessonProgressRecord progressFor(String lessonId) {
    return _progress[lessonId] ??
        LessonProgressRecord(
          lessonId: lessonId,
          completed: false,
          mastery: 0,
          attempts: 0,
          lastOpenedAt: null,
          nextReviewAt: null,
        );
  }

  bool isUnlocked(CurriculumLesson lesson) {
    return lesson.prerequisites.every(
      (id) => progressFor(id).completed,
    );
  }

  CurriculumLesson? nextLesson(List<CurriculumUnit> units) {
    for (final unit in units) {
      for (final lesson in unit.lessons) {
        if (isUnlocked(lesson) &&
            !progressFor(lesson.id).completed) {
          return lesson;
        }
      }
    }
    return null;
  }

  List<CurriculumLesson> reviewQueue(
    List<CurriculumUnit> units,
  ) {
    final now = DateTime.now();
    return [
      for (final unit in units)
        for (final lesson in unit.lessons)
          if (progressFor(lesson.id).completed &&
              progressFor(lesson.id).nextReviewAt != null &&
              !progressFor(lesson.id).nextReviewAt!.isAfter(now))
            lesson,
    ];
  }

  Future<void> markOpened(CurriculumLesson lesson) async {
    final old = progressFor(lesson.id);
    await _save(
      LessonProgressRecord(
        lessonId: lesson.id,
        completed: old.completed,
        mastery: old.mastery,
        attempts: old.attempts + 1,
        lastOpenedAt: DateTime.now(),
        nextReviewAt: old.nextReviewAt,
      ),
    );
  }

  Future<void> completeLesson(
    CurriculumLesson lesson, {
    required double score,
  }) async {
    final old = progressFor(lesson.id);
    final mastery = max(old.mastery, score.clamp(0, 1));
    final interval = _reviewDays(
      mastery,
      old.attempts + 1,
    );

    final record = LessonProgressRecord(
      lessonId: lesson.id,
      completed: true,
      mastery: mastery,
      attempts: old.attempts + 1,
      lastOpenedAt: DateTime.now(),
      nextReviewAt: DateTime.now().add(
        Duration(days: interval),
      ),
    );
    await _save(record);
    await _database.logEvent(
      type: 'lesson_completed',
      lessonId: lesson.id,
      payload: {
        'score': score,
        'mastery': mastery,
        'reviewAfterDays': interval,
      },
    );
  }

  int _reviewDays(double mastery, int attempts) {
    if (mastery < .45) return 1;
    if (mastery < .65) return 3;
    if (mastery < .82) return 7;
    if (attempts < 3) return 14;
    return 30;
  }

  Future<void> _save(LessonProgressRecord record) async {
    _progress[record.lessonId] = record;
    await _database.upsertProgress(record);
    notifyListeners();
  }
}
