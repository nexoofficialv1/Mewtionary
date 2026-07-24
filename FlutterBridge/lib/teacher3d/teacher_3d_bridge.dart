import 'dart:convert';
import 'package:flutter/services.dart';

enum Teacher3DState {
  welcome,
  idle,
  listening,
  speaking,
  thinking,
  praise,
  correction,
  reading,
  pointing,
  writingBoard,
  dancing,
  laughing,
  surprised,
  sleepy,
  adjustGlasses,
  nodding,
}

enum Teacher3DProp { none, book, pointer, chalk }

class Teacher3DBridge {
  Future<bool> get isUnityAvailable async {
    final available =
        await _channel.invokeMethod<bool>('isUnityAvailable');
    return available ?? false;
  }

  Future<Map<String, dynamic>> get bridgeInfo async {
    final value = await _channel.invokeMapMethod<String, dynamic>('bridgeInfo');
    return value ?? <String, dynamic>{};
  }

  static const MethodChannel _channel =
      MethodChannel('mewtionary/teacher3d');

  Future<void> send({
    required Teacher3DState state,
    String message = '',
    Teacher3DProp prop = Teacher3DProp.none,
    int viseme = 0,
    double gazeX = 0,
    double gazeY = 0,
    double duration = 0,
    bool lowMotion = false,
  }) async {
    final command = <String, dynamic>{
      'state': _unityState(state),
      'message': message,
      'prop': _unityProp(prop),
      'viseme': viseme.clamp(0, 6),
      'gazeX': gazeX.clamp(-1, 1),
      'gazeY': gazeY.clamp(-1, 1),
      'duration': duration,
      'lowMotion': lowMotion,
    };

    await _channel.invokeMethod<void>(
      'unitySendMessage',
      <String, dynamic>{
        'gameObject': 'MewtionaryTeacher',
        'method': 'ReceiveCommand',
        'message': jsonEncode(command),
      },
    );
  }

  Future<void> speakStart(String text) => send(
        state: Teacher3DState.speaking,
        message: text,
      );

  Future<void> speakEnd() => send(state: Teacher3DState.idle);

  Future<void> listen() => send(state: Teacher3DState.listening);

  Future<void> praise() => send(
        state: Teacher3DState.praise,
        duration: 2.2,
      );

  Future<void> correctGently() => send(
        state: Teacher3DState.correction,
        duration: 2.0,
      );

  Future<void> showStory() => send(
        state: Teacher3DState.reading,
        prop: Teacher3DProp.book,
      );

  Future<void> pointToBoard() => send(
        state: Teacher3DState.pointing,
        prop: Teacher3DProp.pointer,
      );

  String _unityState(Teacher3DState state) {
    switch (state) {
      case Teacher3DState.writingBoard:
        return 'WritingBoard';
      case Teacher3DState.adjustGlasses:
        return 'AdjustGlasses';
      default:
        final value = state.name;
        return value[0].toUpperCase() + value.substring(1);
    }
  }

  String _unityProp(Teacher3DProp prop) {
    final value = prop.name;
    return value[0].toUpperCase() + value.substring(1);
  }
}
