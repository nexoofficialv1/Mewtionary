# Mewtionary Dictionary Pack Format v1

Each pack contains:

```text
<pack_id>_manifest.json
<pack_id>_entries.jsonl
```

The manifest records pack ID, version, language pair, entry count, license statement and SHA-256 checksum. Every JSONL line contains one English–Bangla entry.

Required entry fields:
- `word`
- `bangla`

Supported optional fields:
- `partOfSpeech`
- `pronunciation`
- `definition`
- `example`
- `exampleBangla`
- `tags`

Imports are transactional, committed in batches of 500 rows, indexed for English and Bangla prefix/contains search, and rejected when the checksum or language pair does not match.

Only original, licensed or public-domain dictionary content may be distributed.
