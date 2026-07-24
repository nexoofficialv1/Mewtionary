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
