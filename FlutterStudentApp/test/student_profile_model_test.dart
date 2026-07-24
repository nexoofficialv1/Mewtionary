import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/models/adaptive_learning_models.dart';
import 'package:mewtionary_student/models/curriculum_models.dart';

void main() {
  test('student profile round-trips through map', () {
    final now = DateTime(2026, 7, 24);
    final profile = StudentProfile(
      name: 'Riya',
      age: 10,
      level: CurriculumLevel.class5,
      createdAt: now,
      updatedAt: now,
    );

    final restored = StudentProfile.fromMap(profile.toMap());
    expect(restored.name, 'Riya');
    expect(restored.level, CurriculumLevel.class5);
  });
}
