import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum LearningFeedbackState {
  idle,
  welcome,
  listening,
  speaking,
  reading,
  writingBoard,
  pointing,
  thinking,
  praise,
  correction,
  dancing,
}

enum LearningFeedbackContext {
  none,
  book,
  pointer,
  chalk,
}

class LearningFeedbackStatus {
  const LearningFeedbackStatus({
    required this.state,
    required this.message,
    required this.speaking,
  });

  final LearningFeedbackState state;
  final String message;
  final bool speaking;

  LearningFeedbackStatus copyWith({
    LearningFeedbackState? state,
    String? message,
    bool? speaking,
  }) {
    return LearningFeedbackStatus(
      state: state ?? this.state,
      message: message ?? this.message,
      speaking: speaking ?? this.speaking,
    );
  }
}

/// Audio/text feedback only.
///
/// The legacy constructor parameter name `teacher` remains in some screens
/// to minimise migration risk, but there is no visible guide, Unity bridge,
/// PlatformView, 3D asset or animation runtime in v2.8.
class LearningFeedbackService extends ChangeNotifier {
  LearningFeedbackService({FlutterTts? tts})
      : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  LearningFeedbackStatus _status = const LearningFeedbackStatus(
    state: LearningFeedbackState.idle,
    message: '',
    speaking: false,
  );

  LearningFeedbackStatus get status => _status;

  Future<void> initialise() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(.43);
    await _tts.setPitch(1.03);
    _tts.setCompletionHandler(() {
      _status = _status.copyWith(
        state: LearningFeedbackState.idle,
        speaking: false,
      );
      notifyListeners();
    });
  }

  Future<void> act({
    required LearningFeedbackState state,
    required String message,
    LearningFeedbackContext prop = LearningFeedbackContext.none,
    bool speak = true,
    double duration = 0,
  }) async {
    _status = _status.copyWith(
      state: state,
      message: message,
      speaking: speak,
    );
    notifyListeners();

    if (speak && message.trim().isNotEmpty) {
      await _tts.stop();
      await _tts.speak(message);
    }
  }

  Future<void> welcome() => act(
        state: LearningFeedbackState.welcome,
        message: 'আজ আমরা আনন্দ করে ইংরেজি শিখব।',
      );

  Future<void> listen() => act(
        state: LearningFeedbackState.listening,
        message: '',
        speak: false,
      );

  Future<void> praise([String? message]) => act(
        state: LearningFeedbackState.praise,
        message: message ?? 'দারুণ! উত্তরটি সঠিক।',
      );

  Future<void> correct(String hint) => act(
        state: LearningFeedbackState.correction,
        message: 'কোনো সমস্যা নেই। $hint',
      );

  Future<void> explainDictionary({
    required String word,
    required String meaning,
    required String example,
  }) async {
    await act(
      state: LearningFeedbackState.speaking,
      message: '$word মানে $meaning। Example: $example',
    );
  }

  Future<void> readStory({
    required String english,
    required String bangla,
    required String state,
  }) async {
    await act(
      state: _stateFromName(state),
      message: '$english $bangla',
    );
  }

  Future<void> stop() async {
    await _tts.stop();
    _status = _status.copyWith(
      state: LearningFeedbackState.idle,
      speaking: false,
    );
    notifyListeners();
  }

  LearningFeedbackState _stateFromName(String value) {
    return LearningFeedbackState.values.firstWhere(
      (item) => item.name.toLowerCase() == value.toLowerCase(),
      orElse: () => LearningFeedbackState.reading,
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
