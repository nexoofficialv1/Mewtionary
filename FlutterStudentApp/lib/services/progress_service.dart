import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_models.dart';

class ProgressService extends ChangeNotifier {
  static const _key = 'mewtionary_progress_v2_2';

  LearningProgress _progress = const LearningProgress();
  LearningProgress get progress => _progress;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      _progress = LearningProgress.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      notifyListeners();
    }
  }

  Future<void> addDictionaryWord() => _update(
        _progress.copyWith(
          dictionaryWords: _progress.dictionaryWords + 1,
          stars: _progress.stars + 1,
        ),
      );

  Future<void> completeGrammar() => _update(
        _progress.copyWith(
          grammarLessons: _progress.grammarLessons + 1,
          stars: _progress.stars + 3,
        ),
      );

  Future<void> completeStory() => _update(
        _progress.copyWith(
          stories: _progress.stories + 1,
          stars: _progress.stars + 2,
        ),
      );

  Future<void> addVoiceAttempt({required bool correct}) => _update(
        _progress.copyWith(
          voiceAttempts: _progress.voiceAttempts + 1,
          stars: _progress.stars + (correct ? 2 : 0),
        ),
      );

  Future<void> reset() => _update(const LearningProgress());

  Future<void> _update(LearningProgress next) async {
    _progress = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(next.toJson()));
  }
}
