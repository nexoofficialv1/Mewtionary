# Changelog


## 2.8.2

### Fixed
- Removed invalid `const` from four `SpeechListenOptions` constructor calls.
- Removed analyzer-reported duplicate curriculum model imports.
- Updated the GitHub APK artifact name to v2.8.2.

### Remaining informational notice
- Flutter's legacy `Radio` `groupValue` and `onChanged` API is deprecated.
  It is non-fatal in the current workflow and does not block compilation.


## 2.8.1

### Fixed
- Corrected `num` to `double` assignments in curriculum and pronunciation scoring.
- Restored access to curriculum level and skill extension getters.
- Corrected invalid `Colors.black67` usage.
- Added a valid Flutter widget smoke test so `flutter create` does not generate an obsolete `MyApp` test.
- Removed unused imports reported by the analyzer.
- Updated color opacity, speech locale and dropdown APIs for current Flutter stable.
- Kept analyzer strict for errors while making deprecation notices non-fatal in CI.

## 2.8.0

### Removed
- Animated/3D visual guide
- Unity project
- Unity Flutter bridge
- Android PlatformView for Unity
- Blender character kit
- Unity Cloud build requirement

### Changed
- App is now Flutter-only
- Learning responses use optional text-to-speech feedback
- Home and module labels no longer refer to a Teacher guide
- GitHub Actions directly builds the Android APK
- Repository now includes mandatory structured documentation

### Preserved
- Dictionary
- Curriculum and learning paths
- Voice and pronunciation activities
- Games, stories, homework and revision
- Mock exams, planner, analytics and certificates
