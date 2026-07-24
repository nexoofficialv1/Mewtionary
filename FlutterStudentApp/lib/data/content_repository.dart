import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/learning_models.dart';

class ContentRepository {
  Future<List<DictionaryEntry>> loadDictionary() async {
    final raw = await rootBundle.loadString(
      'assets/content/dictionary_sample.json',
    );
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => DictionaryEntry.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<List<TenseLesson>> loadTenses() async {
    final raw = await rootBundle.loadString(
      'assets/content/tense_lessons.json',
    );
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => TenseLesson.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<List<StoryLesson>> loadStories() async {
    final raw = await rootBundle.loadString(
      'assets/content/story_lessons.json',
    );
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => StoryLesson.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  List<DictionaryEntry> searchDictionary(
    List<DictionaryEntry> entries,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return entries;

    final exact = entries.where((entry) {
      return entry.word.toLowerCase() == normalized ||
          entry.bangla == query.trim();
    }).toList();

    final startsWith = entries.where((entry) {
      if (exact.contains(entry)) return false;
      return entry.word.toLowerCase().startsWith(normalized) ||
          entry.bangla.startsWith(query.trim());
    }).toList();

    final contains = entries.where((entry) {
      if (exact.contains(entry) || startsWith.contains(entry)) return false;
      return entry.word.toLowerCase().contains(normalized) ||
          entry.bangla.contains(query.trim()) ||
          entry.definition.toLowerCase().contains(normalized);
    }).toList();

    return [...exact, ...startsWith, ...contains];
  }
}
