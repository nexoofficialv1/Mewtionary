# Deployment

## GitHub APK build

1. Push the repository to GitHub.
2. Open **Actions**.
3. Run **Build Mewtionary Flutter-Only APK**.
4. Download the artifact named
   `Mewtionary-v2.8-Flutter-only-debug-apk`.

No Unity Editor, Unity Cloud build target, Unity licence or `unityLibrary`
export is required.

## Production

- Create a secure Android upload keystore.
- Configure release signing outside source control.
- Build an Android App Bundle with `flutter build appbundle --release`.
- Test the signed bundle through Play Console internal testing.
