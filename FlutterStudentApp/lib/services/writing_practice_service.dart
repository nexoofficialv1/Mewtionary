import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/mewtionary_database.dart';
import '../models/adaptive_learning_models.dart';

class WritingPracticeService {
  WritingPracticeService({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;

  Future<List<WritingPrompt>> loadPrompts(
    CurriculumLevel level,
  ) async {
    final raw = await rootBundle.loadString(
      'assets/content/writing_prompts.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final prompts = (decoded['prompts'] as List<dynamic>)
        .map(
          (item) => WritingPrompt.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    final exact = prompts
        .where((prompt) => prompt.levelId == level.id)
        .toList();
    return exact.isEmpty ? prompts.take(3).toList() : exact;
  }

  Future<void> saveAttempt({
    required WritingPrompt prompt,
    required int strokeCount,
    required int selfScore,
  }) {
    return _database.saveWritingAttempt(
      promptId: prompt.id,
      promptText: prompt.guideText,
      strokeCount: strokeCount,
      selfScore: selfScore,
    );
  }
}
