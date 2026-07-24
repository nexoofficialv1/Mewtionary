# Mewtionary v2.8.3 Android SDK Build Fix

## Failure

Gradle stopped at `:file_picker:checkDebugAarMetadata` because the old
`file_picker 8.1.7` Android module compiled against API 34 while its resolved
lifecycle dependency required applications and libraries to compile against
API 36 or later.

## Fix

- `file_picker: ^11.0.2`
- static FilePicker API migration
- Flutter SDK pinned to 3.44.7
- Android SDK Platform 36 installed in CI
- generated app `compileSdk` forced to 36
- target SDK and minimum SDK remain independently controlled by Flutter

## Expected CI flow

1. Validate content
2. Generate Android host
3. Patch permissions and compile SDK
4. Resolve packages
5. Analyze
6. Test
7. Build debug APK
8. Upload artifact
