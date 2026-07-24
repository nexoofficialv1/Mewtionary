# Mewtionary Teacher 3D Flutter Bridge v2.1

This package contains:
- Dart Teacher3DBridge
- high-level Teacher3DLessonController
- reflection-based Android plugin
- example lesson controls

## Important
The plugin compiles without direct Unity classes because it uses reflection. Commands work only after Unity has been exported as an Android Library and included in the Flutter host application.

## Check connection
```dart
final bridge = Teacher3DBridge();
final connected = await bridge.isUnityAvailable;
```

## Send a lesson action
```dart
final lesson = Teacher3DLessonController();

await lesson.explainDictionaryWord(
  word: 'Beautiful',
  meaning: 'সুন্দর',
  example: 'The flower is beautiful.',
);
```

## Expected Unity endpoint
```text
MewtionaryTeacher.ReceiveCommand(json)
```
