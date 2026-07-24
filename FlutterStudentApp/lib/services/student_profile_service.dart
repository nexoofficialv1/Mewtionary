import 'package:flutter/foundation.dart';

import '../data/mewtionary_database.dart';
import '../models/adaptive_learning_models.dart';
import '../models/curriculum_models.dart';

class StudentProfileService extends ChangeNotifier {
  StudentProfileService({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;

  StudentProfile _profile = StudentProfile(
    name: 'বন্ধু',
    age: 9,
    level: CurriculumLevel.class4,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  StudentProfile get profile => _profile;

  Future<void> load() async {
    final saved = await _database.loadStudentProfile();
    if (saved != null) {
      _profile = saved;
      notifyListeners();
    }
  }

  Future<void> save({
    required String name,
    required int age,
    required CurriculumLevel level,
  }) async {
    final now = DateTime.now();
    _profile = _profile.copyWith(
      name: name.trim().isEmpty ? 'বন্ধু' : name.trim(),
      age: age.clamp(4, 16),
      level: level,
      updatedAt: now,
    );
    await _database.saveStudentProfile(_profile);
    await _database.logEvent(
      type: 'profile_updated',
      payload: {
        'name': _profile.name,
        'age': _profile.age,
        'level': _profile.level.id,
      },
    );
    notifyListeners();
  }

  Future<void> applyDiagnosticLevel(
    CurriculumLevel level,
  ) async {
    await save(
      name: _profile.name,
      age: _profile.age,
      level: level,
    );
  }
}
