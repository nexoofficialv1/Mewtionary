# Mewtionary v2.8.5 Java Setup Fix

## Failure

`actions/setup-java` stopped with:

```text
No file ... matched to [**/*.gradle*, **/gradle-wrapper.properties, ...]
```

## Cause

The workflow enabled `cache: gradle` in the Java setup step. Mewtionary
generates its Android host later with `flutter create`, so no Gradle files
existed when `setup-java` attempted to calculate its cache key.

## Fix

- use `actions/setup-java@v5`
- configure Temurin Java 17
- remove `cache: gradle`
- continue generating Android files after Flutter setup
- retain Android SDK 36 and Build Tools 36.0.0

Gradle caching is optional and must not run before the Gradle project exists.
