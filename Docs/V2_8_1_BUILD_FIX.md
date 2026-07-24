# Mewtionary v2.8.1 Build Fix

This patch addresses the first GitHub Actions analyzer report.

Fixed error categories:
- `num` assigned to `double`
- unavailable curriculum extension getters
- invalid Flutter color constant
- generated `MyApp` widget test
- unused imports

Compatibility updates:
- `Color.withValues(alpha: ...)`
- `SpeechListenOptions.localeId`
- `DropdownButtonFormField.initialValue`
- analyzer deprecations are non-fatal, while compile errors remain fatal

Local limitation:
Flutter SDK is not installed in this environment. GitHub Actions remains
the source of truth for actual analysis, tests and APK compilation.
