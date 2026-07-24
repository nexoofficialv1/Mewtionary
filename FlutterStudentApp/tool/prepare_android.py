#!/usr/bin/env python3
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
manifest = root / "android" / "app" / "src" / "main" / "AndroidManifest.xml"

if not manifest.exists():
    raise SystemExit("AndroidManifest.xml not found. Run flutter create --platforms=android . first.")

text = manifest.read_text(encoding="utf-8")
permissions = [
    '<uses-permission android:name="android.permission.RECORD_AUDIO" />',
    '<uses-permission android:name="android.permission.INTERNET" />',
]

for permission in permissions:
    if permission not in text:
        text = text.replace("<manifest", "<manifest", 1)
        insert = text.find(">")
        text = text[:insert + 1] + "\n    " + permission + text[insert + 1:]

if 'android:usesCleartextTraffic=' not in text:
    text = text.replace(
        "<application",
        '<application android:usesCleartextTraffic="false"',
        1,
    )

manifest.write_text(text, encoding="utf-8")
print("Android permissions prepared.")


# Android 16 / API 36 compile compatibility.
#
# file_picker 11 uses Flutter's compile SDK, but this explicit patch
# protects the generated host project from older template defaults.
android_app = root / "android" / "app"
kotlin_gradle = android_app / "build.gradle.kts"
groovy_gradle = android_app / "build.gradle"

if kotlin_gradle.exists():
    gradle_text = kotlin_gradle.read_text(encoding="utf-8")
    gradle_text, replacements = re.subn(
        r"compileSdk\s*=\s*(?:flutter\.compileSdkVersion|\d+)",
        "compileSdk = 36",
        gradle_text,
        count=1,
    )
    if replacements == 0 and "compileSdk = 36" not in gradle_text:
        raise SystemExit(
            "Could not set compileSdk 36 in android/app/build.gradle.kts"
        )
    kotlin_gradle.write_text(gradle_text, encoding="utf-8")
    print("Android Kotlin Gradle compileSdk set to 36.")
elif groovy_gradle.exists():
    gradle_text = groovy_gradle.read_text(encoding="utf-8")
    gradle_text, replacements = re.subn(
        r"compileSdkVersion\s+(?:flutter\.compileSdkVersion|\d+)",
        "compileSdkVersion 36",
        gradle_text,
        count=1,
    )
    if replacements == 0 and "compileSdkVersion 36" not in gradle_text:
        raise SystemExit(
            "Could not set compileSdk 36 in android/app/build.gradle"
        )
    groovy_gradle.write_text(gradle_text, encoding="utf-8")
    print("Android Groovy Gradle compileSdk set to 36.")
else:
    raise SystemExit("Android app Gradle file was not found.")
