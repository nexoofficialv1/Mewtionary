# Testing

## Automated

- Content schema and count validation
- Dictionary pack SHA-256 validation
- Unit tests for scoring, models and planner logic
- `flutter analyze`
- `flutter test`
- Debug APK build in GitHub Actions

## Device matrix

- Android 8/9 low-memory device
- Android 12 mid-range device
- Android 14/15 recent device
- Microphone granted and denied
- Offline mode
- Bangla and English keyboard input
- Large imported dictionary pack
- Screen rotation and process restart

## Release gate

No release claim is valid until CI passes and an APK/AAB is installed and
tested on a physical Android device.
