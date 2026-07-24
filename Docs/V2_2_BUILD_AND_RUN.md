# Build and Run — Mewtionary Student App v2.2

## Local Flutter build
From `FlutterStudentApp`:

```bash
flutter create --platforms=android --project-name mewtionary_student .
python3 tool/prepare_android.py
flutter pub get
flutter test
flutter run
```

Without Unity, the app runs in fallback mode.

## GitHub APK build
Push the complete package to a GitHub repository. Run:

```text
Actions → Build Mewtionary Android APK → Run workflow
```

The workflow produces a debug APK artifact.

## Live 3D Teacher
1. Open `UnityProject`.
2. Import and map the final FBX/GLB with the Final Character Setup Wizard.
3. Export Unity as an Android Library.
4. Add the generated `unityLibrary` module to the Flutter Android host.
5. Ensure the Unity runtime object is named `MewtionaryTeacher`.
6. The Flutter `AndroidView` will display the Unity viewport and commands will use `ReceiveCommand`.

## Required Android permissions
- RECORD_AUDIO
- INTERNET

The preparation script adds them to the generated Flutter Android manifest.
