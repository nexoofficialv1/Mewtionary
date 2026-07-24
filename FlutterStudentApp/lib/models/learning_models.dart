enum LearningMode {
  earlyLearner,
  class1To3,
  class4To6,
  class7To9,
}

extension LearningModeLabel on LearningMode {
  String get title => switch (this) {
        LearningMode.earlyLearner => 'Early Learner',
        LearningMode.class1To3 => 'Class 1–3',
        LearningMode.class4To6 => 'Class 4–6',
        LearningMode.class7To9 => 'Class 7–9',
      };

  String get subtitle => switch (this) {
        LearningMode.earlyLearner => 'ছবি, শব্দ ও voice-first learning',
        LearningMode.class1To3 => 'Vocabulary, reading ও basic grammar',
        LearningMode.class4To6 => 'Grammar, story, writing ও speaking',
        LearningMode.class7To9 => 'Advanced grammar, composition ও exam practice',
      };
}

class DictionaryEntry {
  const DictionaryEntry({
    required this.word,
    required this.bangla,
    required this.partOfSpeech,
    required this.pronunciation,
    required this.definition,
    required this.example,
    required this.exampleBangla,
  });

  final String word;
  final String bangla;
  final String partOfSpeech;
  final String pronunciation;
  final String definition;
  final String example;
  final String exampleBangla;

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      word: json['word'] as String,
      bangla: json['bangla'] as String,
      partOfSpeech: json['partOfSpeech'] as String,
      pronunciation: json['pronunciation'] as String,
      definition: json['definition'] as String,
      example: json['example'] as String,
      exampleBangla: json['exampleBangla'] as String,
    );
  }
}

class TenseLesson {
  const TenseLesson({
    required this.id,
    required this.title,
    required this.banglaTitle,
    required this.rule,
    required this.examples,
    required this.quiz,
  });

  final String id;
  final String title;
  final String banglaTitle;
  final String rule;
  final List<String> examples;
  final List<TenseQuizQuestion> quiz;

  factory TenseLesson.fromJson(Map<String, dynamic> json) {
    return TenseLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      banglaTitle: json['banglaTitle'] as String,
      rule: json['rule'] as String,
      examples: (json['examples'] as List<dynamic>).cast<String>(),
      quiz: (json['quiz'] as List<dynamic>)
          .map((item) => TenseQuizQuestion.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
    );
  }
}

class TenseQuizQuestion {
  const TenseQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.hint,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String hint;

  factory TenseQuizQuestion.fromJson(Map<String, dynamic> json) {
    return TenseQuizQuestion(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctIndex: json['correctIndex'] as int,
      hint: json['hint'] as String,
    );
  }
}

class StoryLesson {
  const StoryLesson({
    required this.id,
    required this.title,
    required this.banglaTitle,
    required this.pages,
    required this.moral,
    required this.questions,
  });

  final String id;
  final String title;
  final String banglaTitle;
  final List<StoryPage> pages;
  final String moral;
  final List<String> questions;

  factory StoryLesson.fromJson(Map<String, dynamic> json) {
    return StoryLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      banglaTitle: json['banglaTitle'] as String,
      pages: (json['pages'] as List<dynamic>)
          .map((item) => StoryPage.fromJson(item as Map<String, dynamic>))
          .toList(),
      moral: json['moral'] as String,
      questions: (json['questions'] as List<dynamic>).cast<String>(),
    );
  }
}

class StoryPage {
  const StoryPage({
    required this.english,
    required this.bangla,
    required this.teacherState,
  });

  final String english;
  final String bangla;
  final String teacherState;

  factory StoryPage.fromJson(Map<String, dynamic> json) {
    return StoryPage(
      english: json['english'] as String,
      bangla: json['bangla'] as String,
      teacherState: json['teacherState'] as String,
    );
  }
}

class LearningProgress {
  const LearningProgress({
    this.dictionaryWords = 0,
    this.grammarLessons = 0,
    this.stories = 0,
    this.voiceAttempts = 0,
    this.stars = 0,
  });

  final int dictionaryWords;
  final int grammarLessons;
  final int stories;
  final int voiceAttempts;
  final int stars;

  LearningProgress copyWith({
    int? dictionaryWords,
    int? grammarLessons,
    int? stories,
    int? voiceAttempts,
    int? stars,
  }) {
    return LearningProgress(
      dictionaryWords: dictionaryWords ?? this.dictionaryWords,
      grammarLessons: grammarLessons ?? this.grammarLessons,
      stories: stories ?? this.stories,
      voiceAttempts: voiceAttempts ?? this.voiceAttempts,
      stars: stars ?? this.stars,
    );
  }

  Map<String, int> toJson() => {
        'dictionaryWords': dictionaryWords,
        'grammarLessons': grammarLessons,
        'stories': stories,
        'voiceAttempts': voiceAttempts,
        'stars': stars,
      };

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      dictionaryWords: json['dictionaryWords'] as int? ?? 0,
      grammarLessons: json['grammarLessons'] as int? ?? 0,
      stories: json['stories'] as int? ?? 0,
      voiceAttempts: json['voiceAttempts'] as int? ?? 0,
      stars: json['stars'] as int? ?? 0,
    );
  }
}
