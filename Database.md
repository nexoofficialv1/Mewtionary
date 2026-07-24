# Database

Mewtionary uses an offline SQLite database. Current schema version: **5**.

## Main data groups

- Student profile and settings
- Curriculum lesson progress
- Dictionary entries and imported pack metadata
- Diagnostic, practice and revision attempts
- Game/listening/story completion
- Conversation attempts and homework drafts
- Pronunciation attempts
- Mock-exam attempts
- Weekly study tasks
- Rewards, issued badges and certificates

## Rules

- Migrations must be additive and versioned.
- Imported packs must be verified with SHA-256.
- Duplicate dictionary entries must not create uncontrolled copies.
- User progress must remain usable offline.
- No child account data is sent to a remote server in v2.8.
