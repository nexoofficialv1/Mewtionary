import 'curriculum_models.dart';

class ConversationReply {
  const ConversationReply({
    required this.id,
    required this.text,
    required this.expectedKeywords,
    required this.teacherReply,
    required this.nextNodeId,
    required this.score,
  });

  final String id;
  final String text;
  final List<String> expectedKeywords;
  final String teacherReply;
  final String? nextNodeId;
  final int score;

  factory ConversationReply.fromJson(Map<String, dynamic> json) {
    return ConversationReply(
      id: json['id'] as String,
      text: json['text'] as String,
      expectedKeywords:
          (json['expectedKeywords'] as List<dynamic>? ?? const [])
              .cast<String>(),
      teacherReply: json['teacherReply'] as String? ?? '',
      nextNodeId: json['nextNodeId'] as String?,
      score: json['score'] as int? ?? 10,
    );
  }
}

class ConversationNode {
  const ConversationNode({
    required this.id,
    required this.speaker,
    required this.prompt,
    required this.banglaPrompt,
    required this.teacherHint,
    required this.replies,
    required this.isFinal,
  });

  final String id;
  final String speaker;
  final String prompt;
  final String banglaPrompt;
  final String teacherHint;
  final List<ConversationReply> replies;
  final bool isFinal;

  factory ConversationNode.fromJson(Map<String, dynamic> json) {
    return ConversationNode(
      id: json['id'] as String,
      speaker: json['speaker'] as String? ?? 'Partner',
      prompt: json['prompt'] as String,
      banglaPrompt: json['banglaPrompt'] as String? ?? '',
      teacherHint: json['teacherHint'] as String? ?? '',
      replies: (json['replies'] as List<dynamic>? ?? const [])
          .map(
            (item) => ConversationReply.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      isFinal: json['isFinal'] as bool? ?? false,
    );
  }
}

class ConversationScenario {
  const ConversationScenario({
    required this.id,
    required this.levelId,
    required this.title,
    required this.banglaTitle,
    required this.location,
    required this.intro,
    required this.startNodeId,
    required this.nodes,
    required this.xp,
    required this.coins,
  });

  final String id;
  final String levelId;
  final String title;
  final String banglaTitle;
  final String location;
  final String intro;
  final String startNodeId;
  final List<ConversationNode> nodes;
  final int xp;
  final int coins;

  ConversationNode nodeById(String id) {
    return nodes.firstWhere(
      (node) => node.id == id,
      orElse: () => nodes.first,
    );
  }

  factory ConversationScenario.fromJson(Map<String, dynamic> json) {
    return ConversationScenario(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      title: json['title'] as String,
      banglaTitle: json['banglaTitle'] as String,
      location: json['location'] as String? ?? '',
      intro: json['intro'] as String,
      startNodeId: json['startNodeId'] as String,
      nodes: (json['nodes'] as List<dynamic>)
          .map(
            (item) => ConversationNode.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      xp: json['xp'] as int? ?? 20,
      coins: json['coins'] as int? ?? 5,
    );
  }
}

enum HomeworkType {
  sentence,
  paragraph,
  letter,
  notice,
  report,
  composition,
}

extension HomeworkTypeInfo on HomeworkType {
  String get title => switch (this) {
        HomeworkType.sentence => 'Sentence',
        HomeworkType.paragraph => 'Paragraph',
        HomeworkType.letter => 'Letter',
        HomeworkType.notice => 'Notice',
        HomeworkType.report => 'Report',
        HomeworkType.composition => 'Composition',
      };
}

class HomeworkFieldDefinition {
  const HomeworkFieldDefinition({
    required this.key,
    required this.label,
    required this.hint,
    required this.required,
    required this.multiline,
  });

  final String key;
  final String label;
  final String hint;
  final bool required;
  final bool multiline;

  factory HomeworkFieldDefinition.fromJson(
    Map<String, dynamic> json,
  ) {
    return HomeworkFieldDefinition(
      key: json['key'] as String,
      label: json['label'] as String,
      hint: json['hint'] as String? ?? '',
      required: json['required'] as bool? ?? true,
      multiline: json['multiline'] as bool? ?? false,
    );
  }
}

class HomeworkTemplate {
  const HomeworkTemplate({
    required this.id,
    required this.levelId,
    required this.type,
    required this.title,
    required this.banglaTitle,
    required this.instructions,
    required this.fields,
    required this.outputTemplate,
    required this.checklist,
  });

  final String id;
  final String levelId;
  final HomeworkType type;
  final String title;
  final String banglaTitle;
  final String instructions;
  final List<HomeworkFieldDefinition> fields;
  final String outputTemplate;
  final List<String> checklist;

  factory HomeworkTemplate.fromJson(Map<String, dynamic> json) {
    return HomeworkTemplate(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      type: HomeworkType.values.firstWhere(
        (item) => item.name == json['type'],
        orElse: () => HomeworkType.paragraph,
      ),
      title: json['title'] as String,
      banglaTitle: json['banglaTitle'] as String,
      instructions: json['instructions'] as String,
      fields: (json['fields'] as List<dynamic>)
          .map(
            (item) => HomeworkFieldDefinition.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      outputTemplate: json['outputTemplate'] as String,
      checklist:
          (json['checklist'] as List<dynamic>? ?? const [])
              .cast<String>(),
    );
  }
}

class HomeworkDraft {
  const HomeworkDraft({
    required this.id,
    required this.templateId,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  final int? id;
  final String templateId;
  final String title;
  final String content;
  final DateTime updatedAt;

  factory HomeworkDraft.fromMap(Map<String, Object?> map) {
    return HomeworkDraft(
      id: map['id'] as int?,
      templateId: map['template_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class RevisionQuestion {
  const RevisionQuestion({
    required this.id,
    required this.levelId,
    required this.skill,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final String levelId;
  final CurriculumSkill skill;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory RevisionQuestion.fromJson(Map<String, dynamic> json) {
    return RevisionQuestion(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      skill: CurriculumSkill.values.firstWhere(
        (item) => item.name == json['skill'],
        orElse: () => CurriculumSkill.grammar,
      ),
      prompt: json['prompt'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class RevisionResult {
  const RevisionResult({
    required this.correct,
    required this.total,
    required this.skillScores,
  });

  final int correct;
  final int total;
  final Map<CurriculumSkill, double> skillScores;

  double get score => total == 0 ? 0 : correct / total;
}

class ParentReportSnapshot {
  const ParentReportSnapshot({
    required this.studentName,
    required this.levelTitle,
    required this.generatedAt,
    required this.totalXp,
    required this.coins,
    required this.streak,
    required this.weeklyEvents,
    required this.completedLessons,
    required this.totalLessons,
    required this.completedGames,
    required this.completedListening,
    required this.completedStories,
    required this.completedPronunciation,
    required this.passedMockExams,
    required this.completedStudyTasks,
    required this.latestRevisionScore,
    required this.skillMastery,
  });

  final String studentName;
  final String levelTitle;
  final DateTime generatedAt;
  final int totalXp;
  final int coins;
  final int streak;
  final int weeklyEvents;
  final int completedLessons;
  final int totalLessons;
  final int completedGames;
  final int completedListening;
  final int completedStories;
  final int completedPronunciation;
  final int passedMockExams;
  final int completedStudyTasks;
  final double? latestRevisionScore;
  final Map<String, double> skillMastery;
}
