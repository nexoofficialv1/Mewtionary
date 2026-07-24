# Architecture

## Decision

Mewtionary v2.8 is a Flutter-only Android application. The visual guide,
Unity runtime, Unity Android library, Blender kit and native PlatformView
bridge have been removed.

## Layers

```text
Flutter UI
  ├── Dictionary and content screens
  ├── Learning/assessment screens
  ├── Parent and reporting screens
  └── Audio feedback controls
            │
Application services
  ├── Curriculum engine
  ├── Assessment and scoring
  ├── Gamification
  ├── Study planner
  ├── Content-pack validation
  └── Text-to-speech / speech recognition
            │
Local data
  ├── SQLite
  ├── SharedPreferences
  ├── Bundled JSON/JSONL content
  └── User-imported licensed dictionary packs
```

## Runtime dependencies

- Flutter
- SQLite (`sqflite`)
- Shared preferences
- Text-to-speech
- Speech-to-text
- Official file selector, path provider and SHA-256 validation

There is no game engine, 3D renderer, Unity bridge, remote backend or
mandatory internet connection.
