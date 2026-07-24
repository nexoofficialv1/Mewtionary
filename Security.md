# Security

## Current model

- Offline-first and no mandatory login
- No Unity runtime or native game-engine bridge
- No embedded API key
- No remote generative-AI service
- Android microphone permission used only for selected voice activities
- Imported content packs require manifest and SHA-256 verification

## Child safety

- No open social feed
- No unrestricted chat
- No public profile
- Parent-controlled study duration and voice settings
- Reports remain local unless the parent explicitly exports them

## Release requirements

- Use a private production signing key
- Enable Play App Signing
- Review Android permissions before release
- Run dependency and static-analysis checks in CI
