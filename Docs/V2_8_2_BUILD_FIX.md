# Mewtionary v2.8.2 Build Fix

The second GitHub Actions analyzer report showed four compile errors:

- `const_with_non_const` in Conversation Lab
- `const_with_non_const` in Listening Lab
- `const_with_non_const` in Pronunciation Coach
- `const_with_non_const` in Voice Practice

`SpeechListenOptions` is not a const constructor in the resolved package
version, so the `const` keyword was removed.

Duplicate `curriculum_models.dart` imports reported as informational notices
were also removed from the affected files and tests.

The two deprecated `Radio` notices are informational and remain non-fatal.
They can be migrated to `RadioGroup` in a later UI compatibility release.
