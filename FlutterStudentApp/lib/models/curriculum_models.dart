enum CurriculumLevel {
  earlyLearner,
  class1,
  class2,
  class3,
  class4,
  class5,
  class6,
  class7,
  class8,
  class9,
}

extension CurriculumLevelInfo on CurriculumLevel {
  String get id => switch (this) {
        CurriculumLevel.earlyLearner => 'early',
        CurriculumLevel.class1 => 'class_1',
        CurriculumLevel.class2 => 'class_2',
        CurriculumLevel.class3 => 'class_3',
        CurriculumLevel.class4 => 'class_4',
        CurriculumLevel.class5 => 'class_5',
        CurriculumLevel.class6 => 'class_6',
        CurriculumLevel.class7 => 'class_7',
        CurriculumLevel.class8 => 'class_8',
        CurriculumLevel.class9 => 'class_9',
      };

  String get title => switch (this) {
        CurriculumLevel.earlyLearner => 'Early Learner',
        CurriculumLevel.class1 => 'Class 1',
        CurriculumLevel.class2 => 'Class 2',
        CurriculumLevel.class3 => 'Class 3',
        CurriculumLevel.class4 => 'Class 4',
        CurriculumLevel.class5 => 'Class 5',
        CurriculumLevel.class6 => 'Class 6',
        CurriculumLevel.class7 => 'Class 7',
        CurriculumLevel.class8 => 'Class 8',
        CurriculumLevel.class9 => 'Class 9',
      };

  String get banglaTitle => switch (this) {
        CurriculumLevel.earlyLearner => 'প্রায় ৪ বছর বয়স',
        CurriculumLevel.class1 => 'প্রথম শ্রেণি',
        CurriculumLevel.class2 => 'দ্বিতীয় শ্রেণি',
        CurriculumLevel.class3 => 'তৃতীয় শ্রেণি',
        CurriculumLevel.class4 => 'চতুর্থ শ্রেণি',
        CurriculumLevel.class5 => 'পঞ্চম শ্রেণি',
        CurriculumLevel.class6 => 'ষষ্ঠ শ্রেণি',
        CurriculumLevel.class7 => 'সপ্তম শ্রেণি',
        CurriculumLevel.class8 => 'অষ্টম শ্রেণি',
        CurriculumLevel.class9 => 'নবম শ্রেণি',
      };
}

enum CurriculumSkill {
  vocabulary,
  grammar,
  reading,
  listening,
  speaking,
  writing,
  story,
  translation,
}

extension CurriculumSkillInfo on CurriculumSkill {
  String get label => switch (this) {
        CurriculumSkill.vocabulary => 'Vocabulary',
        CurriculumSkill.grammar => 'Grammar',
        CurriculumSkill.reading => 'Reading',
        CurriculumSkill.listening => 'Listening',
        CurriculumSkill.speaking => 'Speaking',
        CurriculumSkill.writing => 'Writing',
        CurriculumSkill.story => 'Story',
        CurriculumSkill.translation => 'Translation',
      };
}

class CurriculumUnit {
  const CurriculumUnit({
    required this.id,
    required this.levelId,
    required this.title,
    required this.banglaTitle,
    required this.description,
    required this.order,
    required this.lessons,
  });

  final String id;
  final String levelId;
  final String title;
  final String banglaTitle;
  final String description;
  final int order;
  final List<CurriculumLesson> lessons;

  factory CurriculumUnit.fromJson(Map<String, dynamic> json) {
    return CurriculumUnit(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      title: json['title'] as String,
      banglaTitle: json['banglaTitle'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      lessons: (json['lessons'] as List<dynamic>)
          .map((item) => CurriculumLesson.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
    );
  }
}

class CurriculumLesson {
  const CurriculumLesson({
    required this.id,
    required this.title,
    required this.banglaTitle,
    required this.skill,
    required this.estimatedMinutes,
    required this.teacherState,
    required this.explanation,
    required this.activities,
    required this.prerequisites,
    required this.stars,
  });

  final String id;
  final String title;
  final String banglaTitle;
  final CurriculumSkill skill;
  final int estimatedMinutes;
  final String teacherState;
  final String explanation;
  final List<Map<String, dynamic>> activities;
  final List<String> prerequisites;
  final int stars;

  factory CurriculumLesson.fromJson(Map<String, dynamic> json) {
    final content = Map<String, dynamic>.from(
      json['content'] as Map<String, dynamic>? ?? const {},
    );
    return CurriculumLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      banglaTitle: json['banglaTitle'] as String,
      skill: CurriculumSkill.values.firstWhere(
        (item) => item.name == json['skill'],
        orElse: () => CurriculumSkill.vocabulary,
      ),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 5,
      teacherState: json['teacherState'] as String? ?? 'speaking',
      explanation: content['explanation'] as String? ?? '',
      activities: (json['activities'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(
                item as Map<String, dynamic>,
              ))
          .toList(),
      prerequisites:
          (json['prerequisites'] as List<dynamic>? ?? const []).cast<String>(),
      stars: json['stars'] as int? ?? 1,
    );
  }
}

class LessonProgressRecord {
  const LessonProgressRecord({
    required this.lessonId,
    required this.completed,
    required this.mastery,
    required this.attempts,
    required this.lastOpenedAt,
    required this.nextReviewAt,
  });

  final String lessonId;
  final bool completed;
  final double mastery;
  final int attempts;
  final DateTime? lastOpenedAt;
  final DateTime? nextReviewAt;

  Map<String, Object?> toMap() => {
        'lesson_id': lessonId,
        'completed': completed ? 1 : 0,
        'mastery': mastery,
        'attempts': attempts,
        'last_opened_at': lastOpenedAt?.toIso8601String(),
        'next_review_at': nextReviewAt?.toIso8601String(),
      };

  factory LessonProgressRecord.fromMap(Map<String, Object?> map) {
    return LessonProgressRecord(
      lessonId: map['lesson_id'] as String,
      completed: (map['completed'] as int? ?? 0) == 1,
      mastery: (map['mastery'] as num? ?? 0).toDouble(),
      attempts: map['attempts'] as int? ?? 0,
      lastOpenedAt:
          DateTime.tryParse(map['last_opened_at'] as String? ?? ''),
      nextReviewAt:
          DateTime.tryParse(map['next_review_at'] as String? ?? ''),
    );
  }
}

class DictionaryPackManifest {
  const DictionaryPackManifest({
    required this.packId,
    required this.name,
    required this.version,
    required this.languagePair,
    required this.entryCount,
    required this.license,
    required this.sha256,
  });

  final String packId;
  final String name;
  final String version;
  final String languagePair;
  final int entryCount;
  final String license;
  final String sha256;

  factory DictionaryPackManifest.fromJson(Map<String, dynamic> json) {
    return DictionaryPackManifest(
      packId: json['packId'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      languagePair: json['languagePair'] as String,
      entryCount: json['entryCount'] as int,
      license: json['license'] as String,
      sha256: json['sha256'] as String,
    );
  }
}
