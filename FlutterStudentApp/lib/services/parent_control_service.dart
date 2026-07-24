import 'package:flutter/foundation.dart';

import '../data/mewtionary_database.dart';

class ParentControlState {
  const ParentControlState({
    this.dailyMinutes = 30,
    this.voiceEnabled = true,
    this.banglaSupport = true,
    this.lowMotion = false,
  });

  final int dailyMinutes;
  final bool voiceEnabled;
  final bool banglaSupport;
  final bool lowMotion;

  ParentControlState copyWith({
    int? dailyMinutes,
    bool? voiceEnabled,
    bool? banglaSupport,
    bool? lowMotion,
  }) {
    return ParentControlState(
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      banglaSupport: banglaSupport ?? this.banglaSupport,
      lowMotion: lowMotion ?? this.lowMotion,
    );
  }
}

class ParentControlService extends ChangeNotifier {
  ParentControlService({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;
  ParentControlState _state = const ParentControlState();

  ParentControlState get state => _state;

  Future<void> load() async {
    _state = ParentControlState(
      dailyMinutes: int.tryParse(
            await _database.getParentSetting('daily_minutes') ?? '',
          ) ??
          30,
      voiceEnabled:
          await _database.getParentSetting('voice_enabled') != 'false',
      banglaSupport:
          await _database.getParentSetting('bangla_support') != 'false',
      lowMotion:
          await _database.getParentSetting('low_motion') == 'true',
    );
    notifyListeners();
  }

  Future<void> setDailyMinutes(int value) async {
    _state = _state.copyWith(dailyMinutes: value.clamp(10, 120));
    notifyListeners();
    await _database.setParentSetting(
      'daily_minutes',
      _state.dailyMinutes.toString(),
    );
  }

  Future<void> setVoiceEnabled(bool value) async {
    _state = _state.copyWith(voiceEnabled: value);
    notifyListeners();
    await _database.setParentSetting(
      'voice_enabled',
      value.toString(),
    );
  }

  Future<void> setBanglaSupport(bool value) async {
    _state = _state.copyWith(banglaSupport: value);
    notifyListeners();
    await _database.setParentSetting(
      'bangla_support',
      value.toString(),
    );
  }

  Future<void> setLowMotion(bool value) async {
    _state = _state.copyWith(lowMotion: value);
    notifyListeners();
    await _database.setParentSetting(
      'low_motion',
      value.toString(),
    );
  }
}
