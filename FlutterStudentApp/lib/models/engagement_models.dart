enum MiniGameType {
  wordMatch,
  spelling,
  sentenceBuilder,
}

extension MiniGameTypeInfo on MiniGameType {
  String get title => switch (this) {
        MiniGameType.wordMatch => 'Word Match',
        MiniGameType.spelling => 'Spelling Builder',
        MiniGameType.sentenceBuilder => 'Sentence Builder',
      };

  String get banglaTitle => switch (this) {
        MiniGameType.wordMatch => 'শব্দের অর্থ মিলাও',
        MiniGameType.spelling => 'বানান তৈরি করো',
        MiniGameType.sentenceBuilder => 'বাক্য সাজাও',
      };
}

class MiniGameChallenge {
  const MiniGameChallenge({
    required this.id,
    required this.levelId,
    required this.type,
    required this.prompt,
    required this.answer,
    required this.options,
    required this.hint,
    required this.xp,
    required this.coins,
  });

  final String id;
  final String levelId;
  final MiniGameType type;
  final String prompt;
  final String answer;
  final List<String> options;
  final String hint;
  final int xp;
  final int coins;

  factory MiniGameChallenge.fromJson(Map<String, dynamic> json) {
    return MiniGameChallenge(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      type: MiniGameType.values.firstWhere(
        (item) => item.name == json['type'],
        orElse: () => MiniGameType.wordMatch,
      ),
      prompt: json['prompt'] as String,
      answer: json['answer'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      hint: json['hint'] as String? ?? '',
      xp: json['xp'] as int? ?? 10,
      coins: json['coins'] as int? ?? 2,
    );
  }
}

class ListeningExercise {
  const ListeningExercise({
    required this.id,
    required this.levelId,
    required this.title,
    required this.english,
    required this.bangla,
    required this.mode,
    required this.options,
    required this.correctIndex,
    required this.xp,
    required this.coins,
  });

  final String id;
  final String levelId;
  final String title;
  final String english;
  final String bangla;
  final String mode;
  final List<String> options;
  final int correctIndex;
  final int xp;
  final int coins;

  factory ListeningExercise.fromJson(Map<String, dynamic> json) {
    return ListeningExercise(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      title: json['title'] as String,
      english: json['english'] as String,
      bangla: json['bangla'] as String,
      mode: json['mode'] as String? ?? 'mcq',
      options: (json['options'] as List<dynamic>? ?? const [])
          .cast<String>(),
      correctIndex: json['correctIndex'] as int? ?? 0,
      xp: json['xp'] as int? ?? 10,
      coins: json['coins'] as int? ?? 2,
    );
  }
}

class AdventureVocabulary {
  const AdventureVocabulary({
    required this.word,
    required this.bangla,
  });

  final String word;
  final String bangla;

  factory AdventureVocabulary.fromJson(Map<String, dynamic> json) {
    return AdventureVocabulary(
      word: json['word'] as String,
      bangla: json['bangla'] as String,
    );
  }
}

class AdventurePage {
  const AdventurePage({
    required this.english,
    required this.bangla,
    required this.teacherState,
  });

  final String english;
  final String bangla;
  final String teacherState;

  factory AdventurePage.fromJson(Map<String, dynamic> json) {
    return AdventurePage(
      english: json['english'] as String,
      bangla: json['bangla'] as String,
      teacherState: json['teacherState'] as String? ?? 'reading',
    );
  }
}

class AdventureQuestion {
  const AdventureQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.hint,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String hint;

  factory AdventureQuestion.fromJson(Map<String, dynamic> json) {
    return AdventureQuestion(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctIndex: json['correctIndex'] as int,
      hint: json['hint'] as String? ?? '',
    );
  }
}

class StoryAdventure {
  const StoryAdventure({
    required this.id,
    required this.levelId,
    required this.title,
    required this.banglaTitle,
    required this.summary,
    required this.pages,
    required this.vocabulary,
    required this.questions,
    required this.moral,
    required this.xp,
    required this.coins,
  });

  final String id;
  final String levelId;
  final String title;
  final String banglaTitle;
  final String summary;
  final List<AdventurePage> pages;
  final List<AdventureVocabulary> vocabulary;
  final List<AdventureQuestion> questions;
  final String moral;
  final int xp;
  final int coins;

  factory StoryAdventure.fromJson(Map<String, dynamic> json) {
    return StoryAdventure(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      title: json['title'] as String,
      banglaTitle: json['banglaTitle'] as String,
      summary: json['summary'] as String,
      pages: (json['pages'] as List<dynamic>)
          .map((item) => AdventurePage.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
      vocabulary: (json['vocabulary'] as List<dynamic>)
          .map((item) => AdventureVocabulary.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
      questions: (json['questions'] as List<dynamic>)
          .map((item) => AdventureQuestion.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
      moral: json['moral'] as String,
      xp: json['xp'] as int? ?? 20,
      coins: json['coins'] as int? ?? 5,
    );
  }
}

class RewardWallet {
  const RewardWallet({
    required this.xp,
    required this.coins,
    required this.streak,
    required this.lastActivityDate,
  });

  final int xp;
  final int coins;
  final int streak;
  final DateTime? lastActivityDate;

  int get level => 1 + (xp ~/ 100);
  int get xpInsideLevel => xp % 100;
  double get levelProgress => xpInsideLevel / 100;

  RewardWallet copyWith({
    int? xp,
    int? coins,
    int? streak,
    DateTime? lastActivityDate,
  }) {
    return RewardWallet(
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  factory RewardWallet.fromMap(Map<String, Object?> map) {
    return RewardWallet(
      xp: map['xp'] as int? ?? 0,
      coins: map['coins'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
      lastActivityDate: DateTime.tryParse(
        map['last_activity_date'] as String? ?? '',
      ),
    );
  }
}

class BadgeDefinition {
  const BadgeDefinition({
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

  factory BadgeDefinition.fromJson(Map<String, dynamic> json) {
    return BadgeDefinition(
      id: json['id'] as String,
      title: json['title'] as String,
      banglaTitle: json['banglaTitle'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      ruleType: json['ruleType'] as String,
      threshold: json['threshold'] as int,
    );
  }
}

class BadgeStatus {
  const BadgeStatus({
    required this.definition,
    required this.unlocked,
    required this.unlockedAt,
  });

  final BadgeDefinition definition;
  final bool unlocked;
  final DateTime? unlockedAt;
}
