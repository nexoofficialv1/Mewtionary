import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mewtionary_teacher3d_bridge/mewtionary_teacher3d_bridge.dart';

class TeacherStatus {
  const TeacherStatus({
    required this.state,
    required this.message,
    required this.unityAvailable,
    required this.speaking,
  });

  final Teacher3DState state;
  final String message;
  final bool unityAvailable;
  final bool speaking;

  TeacherStatus copyWith({
    Teacher3DState? state,
    String? message,
    bool? unityAvailable,
    bool? speaking,
  }) {
    return TeacherStatus(
      state: state ?? this.state,
      message: message ?? this.message,
      unityAvailable: unityAvailable ?? this.unityAvailable,
      speaking: speaking ?? this.speaking,
    );
  }
}

class TeacherOrchestrator extends ChangeNotifier {
  TeacherOrchestrator({
    Teacher3DBridge? bridge,
    FlutterTts? tts,
  })  : _bridge = bridge ?? Teacher3DBridge(),
        _tts = tts ?? FlutterTts();

  final Teacher3DBridge _bridge;
  final FlutterTts _tts;

  TeacherStatus _status = const TeacherStatus(
    state: Teacher3DState.idle,
    message: 'আমি শেখানোর জন্য প্রস্তুত।',
    unityAvailable: false,
    speaking: false,
  );

  TeacherStatus get status => _status;

  Future<void> initialise() async {
    final available = await _bridge.isUnityAvailable;
    _status = _status.copyWith(unityAvailable: available);
    notifyListeners();

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(.43);
    await _tts.setPitch(1.03);

    _tts.setCompletionHandler(() {
      _status = _status.copyWith(
        state: Teacher3DState.idle,
        speaking: false,
      );
      notifyListeners();
      unawaited(_bridge.send(state: Teacher3DState.idle));
    });
  }

  Future<void> act({
    required Teacher3DState state,
    required String message,
    Teacher3DProp prop = Teacher3DProp.none,
    bool speak = true,
    double duration = 0,
  }) async {
    _status = _status.copyWith(
      state: state,
      message: message,
      speaking: speak,
    );
    notifyListeners();

    await _bridge.send(
      state: state,
      message: message,
      prop: prop,
      duration: duration,
    );

    if (speak && message.trim().isNotEmpty) {
      await _tts.stop();
      await _tts.speak(message);
    }
  }

  Future<void> welcome() => act(
        state: Teacher3DState.welcome,
        message: 'হ্যালো বন্ধু! আজ আমরা আনন্দ করে ইংরেজি শিখব।',
        prop: Teacher3DProp.book,
      );

  Future<void> listen() => act(
        state: Teacher3DState.listening,
        message: 'আমি শুনছি। এখন তুমি বলো।',
        speak: false,
      );

  Future<void> praise([String? message]) => act(
        state: Teacher3DState.praise,
        message: message ?? 'দারুণ! তুমি একদম ঠিক বলেছ।',
        duration: 2.2,
      );

  Future<void> correct(String hint) => act(
        state: Teacher3DState.correction,
        message: 'কোনো সমস্যা নেই। $hint',
        duration: 2.4,
      );

  Future<void> explainDictionary({
    required String word,
    required String meaning,
    required String example,
  }) async {
    await act(
      state: Teacher3DState.speaking,
      message: '$word মানে $meaning।',
    );
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await act(
      state: Teacher3DState.pointing,
      message: 'Example: $example',
      prop: Teacher3DProp.pointer,
    );
  }

  Future<void> readStory({
    required String english,
    required String bangla,
    required String state,
  }) async {
    final teacherState = _stateFromName(state);
    await act(
      state: teacherState,
      message: '$english $bangla',
      prop: Teacher3DProp.book,
    );
  }

  Future<void> stop() async {
    await _tts.stop();
    _status = _status.copyWith(
      state: Teacher3DState.idle,
      speaking: false,
    );
    notifyListeners();
    await _bridge.send(state: Teacher3DState.idle);
  }

  Teacher3DState _stateFromName(String value) {
    return Teacher3DState.values.firstWhere(
      (state) => state.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Teacher3DState.reading,
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
