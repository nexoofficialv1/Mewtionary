# Changelog


## 2.8.6

### Fixed
- Removed the `file_picker` dependency and its failing Android plugin
  registration.
- Migrated dictionary-pack imports to Flutter's official `file_selector`.
- Added `path_provider` for safe local report, homework and certificate
  exports.
- Exports are stored inside a `Mewtionary` folder in Downloads when the
  platform exposes that directory, with application documents as fallback.
- Android host files, `.dart_tool` and build output are removed before
  `flutter create`, preventing stale generated plugin registrants.
- Updated APK artifact name to v2.8.6.


## 2.8.5

### Fixed
- Removed premature Gradle dependency caching from the Java setup step.
- Updated `actions/setup-java` from v4 to v5 (Node 24 runtime).
- Prevented setup failure before Flutter generates the Android Gradle project.
- Updated the debug APK artifact name to v2.8.5.

### Root cause
- `cache: gradle` was executed before `flutter create`.
- At that point the repository contained no `build.gradle`,
  `gradle-wrapper.properties`, or version-catalog files.
- `setup-java` therefore failed while calculating the Gradle cache key.


## 2.8.4

### Fixed
- Corrected GitHub Actions YAML indentation.
- Moved Android SDK 36 installation inside the build job steps.
- Added Java 17 setup and Android Actions SDK setup.
- Added workflow timeout, version diagnostics and APK existence validation.
- Removed the exact Flutter patch pin and used the current stable channel.
- Updated the APK artifact name to v2.8.4.


## 2.8.3

### Fixed
- Upgraded `file_picker` from 8.1.7 to 11.0.2.
- Migrated FilePicker calls from the legacy instance API to static methods.
- Enforced Android `compileSdk = 36` in the generated Flutter host project.
- Added Android SDK Platform 36 and Build Tools 36.0.0 installation to CI.
- Pinned GitHub Actions to Flutter 3.44.7 for reproducible builds.
- Updated minimum Dart SDK to 3.4.

### Build issue addressed
- AAR metadata failure where `flutter_plugin_android_lifecycle` required
  compile SDK 36 while the old `file_picker` Android module compiled
  against Android 34.


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
