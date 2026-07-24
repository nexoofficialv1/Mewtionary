# Mewtionary v2.8.4 Workflow Syntax Fix

## Symptom

GitHub Actions displayed failure immediately, showed no duration or
artifacts, and said the workflow graph could not be generated.

## Cause

The `Install Android SDK 36` item was written outside the `jobs.build.steps`
list because of incorrect YAML indentation. GitHub therefore rejected the
workflow before allocating a runner.

## Fix

- rebuilt the workflow with valid indentation
- Java 17 setup
- Flutter stable setup
- Android SDK setup
- Android API 36 and Build Tools 36 installation
- content validation, analysis, tests and APK build
- explicit APK existence check
- artifact upload with failure protection
