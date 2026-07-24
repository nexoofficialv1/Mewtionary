import 'curriculum_models.dart';
export 'curriculum_models.dart';

class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.age,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  final String name;
  final int age;
  final CurriculumLevel level;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentProfile copyWith({
    String? name,
    int? age,
    CurriculumLevel? level,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'profile_id': 1,
        'name': name,
        'age': age,
        'level_id': level.id,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory StudentProfile.fromMap(Map<String, Object?> map) {
    final levelId = map['level_id'] as String? ?? 'class_4';
    return StudentProfile(
      name: map['name'] as String? ?? 'বন্ধু',
      age: map['age'] as int? ?? 9,
      level: CurriculumLevel.values.firstWhere(
        (item) => item.id == levelId,
        orElse: () => CurriculumLevel.class4,
      ),
      createdAt: DateTime.tryParse(
            map['created_at'] as String? ?? '',
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
            map['updated_at'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}

class DiagnosticQuestion {
  const DiagnosticQuestion({
    required this.id,
    required this.levelRank,
    required this.skill,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.hint,
  });

  final String id;
  final int levelRank;
  final CurriculumSkill skill;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String hint;

  factory DiagnosticQuestion.fromJson(Map<String, dynamic> json) {
    return DiagnosticQuestion(
      id: json['id'] as String,
      levelRank: json['levelRank'] as int,
      skill: CurriculumSkill.values.firstWhere(
        (item) => item.name == json['skill'],
        orElse: () => CurriculumSkill.vocabulary,
      ),
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctIndex: json['correctIndex'] as int,
      hint: json['hint'] as String? ?? '',
    );
  }
}

class DiagnosticResult {
  const DiagnosticResult({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.recommendedLevel,
    required this.skillScores,
    required this.completedAt,
  });

  final double score;
  final int correctAnswers;
  final int totalQuestions;
  final CurriculumLevel recommendedLevel;
  final Map<CurriculumSkill, double> skillScores;
  final DateTime completedAt;

  Map<String, Object?> toMap() => {
        'score': score,
        'correct_answers': correctAnswers,
        'total_questions': totalQuestions,
        'recommended_level_id': recommendedLevel.id,
        'skill_scores_json': skillScores.map(
          (key, value) => MapEntry(key.name, value),
        ),
        'completed_at': completedAt.toIso8601String(),
      };
}

enum DailyPlanItemType {
  review,
  lesson,
  dictionary,
  voice,
  writing,
  game,
  listening,
  conversation,
  revision,
  homework,
  pronunciation,
  mockExam,
}

class DailyPlanItem {
  const DailyPlanItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.type,
    required this.route,
    this.lessonId,
  });

  final String id;
  final String title;
  final String subtitle;
  final int minutes;
  final DailyPlanItemType type;
  final String route;
  final String? lessonId;
}

class PronunciationScore {
  const PronunciationScore({
    required this.total,
    required this.wordCoverage,
    required this.sequenceAccuracy,
    required this.missingWords,
    required this.extraWords,
  });

  final double total;
  final double wordCoverage;
  final double sequenceAccuracy;
  final List<String> missingWords;
  final List<String> extraWords;
}

class WritingPrompt {
  const WritingPrompt({
    required this.id,
    required this.levelId,
    required this.title,
    required this.guideText,
    required this.instruction,
  });

  final String id;
  final String levelId;
  final String title;
  final String guideText;
  final String instruction;

  factory WritingPrompt.fromJson(Map<String, dynamic> json) {
    return WritingPrompt(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      title: json['title'] as String,
      guideText: json['guideText'] as String,
      instruction: json['instruction'] as String,
    );
  }
}

class SkillAnalytics {
  const SkillAnalytics({
    required this.skill,
    required this.mastery,
    required this.completed,
    required this.total,
  });

  final CurriculumSkill skill;
  final double mastery;
  final int completed;
  final int total;
}

class LearningAnalyticsSnapshot {
  const LearningAnalyticsSnapshot({
    required this.completedLessons,
    required this.totalLessons,
    required this.weeklyEvents,
    required this.reviewDue,
    required this.currentStreak,
    required this.skills,
  });

  final int completedLessons;
  final int totalLessons;
  final int weeklyEvents;
  final int reviewDue;
  final int currentStreak;
  final List<SkillAnalytics> skills;
}
