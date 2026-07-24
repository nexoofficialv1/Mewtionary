# Mewtionary v2.8.6 File Plugin Migration

## Failure

Android Java compilation failed because Flutter generated a registration
call for `com.mr.flutter.plugin.filepicker.FilePickerPlugin`, but that class
was unavailable in the compiled plugin output.

## Resolution

`file_picker` has been fully removed.

Import flow:
- official Flutter `file_selector`
- manifest JSON selection
- JSONL/TXT dictionary-data selection
- direct XFile byte reading

Export flow:
- official Flutter `path_provider`
- Downloads/Mewtionary when available
- application Documents/Mewtionary fallback
- no broad legacy storage permission

CI additionally deletes `android`, `.dart_tool` and `build` before running
`flutter create`, so no stale GeneratedPluginRegistrant can survive.
