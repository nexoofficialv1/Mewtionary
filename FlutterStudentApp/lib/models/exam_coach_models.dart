import 'curriculum_models.dart';

class PronunciationExercise {
  const PronunciationExercise({
    required this.id,
    required this.levelId,
    required this.title,
    required this.target,
    required this.bangla,
    required this.syllables,
    required this.focusSounds,
    required this.mouthTip,
    required this.minimalPairs,
    required this.xp,
    required this.coins,
  });

  final String id;
  final String levelId;
  final String title;
  final String target;
  final String bangla;
  final List<String> syllables;
  final List<String> focusSounds;
  final String mouthTip;
  final List<String> minimalPairs;
  final int xp;
  final int coins;

  factory PronunciationExercise.fromJson(
    Map<String, dynamic> json,
  ) {
    return PronunciationExercise(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      title: json['title'] as String,
      target: json['target'] as String,
      bangla: json['bangla'] as String? ?? '',
      syllables:
          (json['syllables'] as List<dynamic>? ?? const [])
              .cast<String>(),
      focusSounds:
          (json['focusSounds'] as List<dynamic>? ?? const [])
              .cast<String>(),
      mouthTip: json['mouthTip'] as String? ?? '',
      minimalPairs:
          (json['minimalPairs'] as List<dynamic>? ?? const [])
              .cast<String>(),
      xp: json['xp'] as int? ?? 12,
      coins: json['coins'] as int? ?? 3,
    );
  }
}

enum ExamQuestionType {
  mcq,
  fillBlank,
  rearrange,
  shortAnswer,
}

class MockExamQuestion {
  const MockExamQuestion({
    required this.id,
    required this.type,
    required this.skill,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.acceptedAnswers,
    required this.explanation,
    required this.marks,
  });

  final String id;
  final ExamQuestionType type;
  final CurriculumSkill skill;
  final String prompt;
  final List<String> options;
  final String answer;
  final List<String> acceptedAnswers;
  final String explanation;
  final int marks;

  factory MockExamQuestion.fromJson(Map<String, dynamic> json) {
    return MockExamQuestion(
      id: json['id'] as String,
      type: ExamQuestionType.values.firstWhere(
        (item) => item.name == json['type'],
        orElse: () => ExamQuestionType.mcq,
      ),
      skill: CurriculumSkill.values.firstWhere(
        (item) => item.name == json['skill'],
        orElse: () => CurriculumSkill.grammar,
      ),
      prompt: json['prompt'] as String,
      options:
          (json['options'] as List<dynamic>? ?? const [])
              .cast<String>(),
      answer: json['answer'] as String,
      acceptedAnswers:
          (json['acceptedAnswers'] as List<dynamic>? ?? const [])
              .cast<String>(),
      explanation: json['explanation'] as String? ?? '',
      marks: json['marks'] as int? ?? 1,
    );
  }
}

class MockExamPaper {
  const MockExamPaper({
    required this.id,
    required this.levelId,
    required this.title,
    required this.banglaTitle,
    required this.durationMinutes,
    required this.instructions,
    required this.questions,
    required this.xp,
    required this.coins,
  });

  final String id;
  final String levelId;
  final String title;
  final String banglaTitle;
  final int durationMinutes;
  final List<String> instructions;
  final List<MockExamQuestion> questions;
  final int xp;
  final int coins;

  int get totalMarks =>
      questions.fold(0, (sum, question) => sum + question.marks);

  factory MockExamPaper.fromJson(Map<String, dynamic> json) {
    return MockExamPaper(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      title: json['title'] as String,
      banglaTitle: json['banglaTitle'] as String,
      durationMinutes: json['durationMinutes'] as int? ?? 15,
      instructions:
          (json['instructions'] as List<dynamic>? ?? const [])
              .cast<String>(),
      questions: (json['questions'] as List<dynamic>)
          .map(
            (item) => MockExamQuestion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      xp: json['xp'] as int? ?? 30,
      coins: json['coins'] as int? ?? 8,
    );
  }
}

class MockExamResult {
  const MockExamResult({
    required this.earnedMarks,
    required this.totalMarks,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.skillScores,
  });

  final int earnedMarks;
  final int totalMarks;
  final int correctAnswers;
  final int totalQuestions;
  final Map<CurriculumSkill, double> skillScores;

  double get percentage =>
      totalMarks == 0 ? 0 : earnedMarks / totalMarks;
}

class StudyTask {
  const StudyTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.plannedDate,
    required this.minutes,
    required this.completed,
    required this.source,
  });

  final int? id;
  final String title;
  final String subtitle;
  final String route;
  final DateTime plannedDate;
  final int minutes;
  final bool completed;
  final String source;

  StudyTask copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? route,
    DateTime? plannedDate,
    int? minutes,
    bool? completed,
    String? source,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      route: route ?? this.route,
      plannedDate: plannedDate ?? this.plannedDate,
      minutes: minutes ?? this.minutes,
      completed: completed ?? this.completed,
      source: source ?? this.source,
    );
  }

  factory StudyTask.fromMap(Map<String, Object?> map) {
    return StudyTask(
      id: map['id'] as int?,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      route: map['route'] as String? ?? '',
      plannedDate: DateTime.parse(
        map['planned_date'] as String,
      ),
      minutes: map['minutes'] as int? ?? 10,
      completed: (map['completed'] as int? ?? 0) == 1,
      source: map['source'] as String? ?? 'manual',
    );
  }
}

class CertificateDefinition {
  const CertificateDefinition({
    required this.id,
    required this.title,
    required this.banglaTitle,
    required this.description,
    required this.icon,
    required this.ruleType,
    required this.threshold,
  });

  final String id;
  final String title;
  final String banglaTitle;
  final String description;
  final String icon;
  final String ruleType;
  final int threshold;

  factory CertificateDefinition.fromJson(
    Map<String, dynamic> json,
  ) {
    return CertificateDefinition(
      id: json['id'] as String,
      title: json['title'] as String,
      banglaTitle: json['banglaTitle'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String? ?? '🏆',
      ruleType: json['ruleType'] as String,
      threshold: json['threshold'] as int,
    );
  }
}

class CertificateStatus {
  const CertificateStatus({
    required this.definition,
    required this.unlocked,
    required this.progress,
  });

  final CertificateDefinition definition;
  final bool unlocked;
  final double progress;
}
