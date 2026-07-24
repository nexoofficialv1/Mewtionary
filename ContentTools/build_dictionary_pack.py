#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path


def clean(value: str | None) -> str:
    return (value or '').strip()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--csv', required=True)
    parser.add_argument('--pack-id', required=True)
    parser.add_argument('--name', required=True)
    parser.add_argument('--version', required=True)
    parser.add_argument('--license', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()

    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    entries: list[dict] = []
    skipped = 0

    with Path(args.csv).open(
        'r',
        encoding='utf-8-sig',
        newline='',
    ) as handle:
        reader = csv.DictReader(handle)
        fields = set(reader.fieldnames or [])
        missing = {'word', 'bangla'} - fields
        if missing:
            raise SystemExit(
                f'Missing CSV columns: {sorted(missing)}'
            )

        for row in reader:
            word = clean(row.get('word'))
            bangla = clean(row.get('bangla'))
            if not word or not bangla:
                skipped += 1
                continue

            entries.append({
                'word': word,
                'bangla': bangla,
                'partOfSpeech':
                    clean(row.get('partOfSpeech')) or 'unknown',
                'pronunciation': clean(row.get('pronunciation')),
                'definition': clean(row.get('definition')),
                'example': clean(row.get('example')),
                'exampleBangla': clean(row.get('exampleBangla')),
                'tags': [
                    item.strip()
                    for item in clean(row.get('tags')).split('|')
                    if item.strip()
                ],
            })

    raw = '\n'.join(
        json.dumps(
            entry,
            ensure_ascii=False,
            separators=(',', ':'),
        )
        for entry in entries
    ).encode('utf-8')

    data_path = output / f'{args.pack_id}_entries.jsonl'
    manifest_path = output / f'{args.pack_id}_manifest.json'
    data_path.write_bytes(raw)

    manifest = {
        'schemaVersion': 1,
        'packId': args.pack_id,
        'name': args.name,
        'version': args.version,
        'languagePair': 'en-bn',
        'entryCount': len(entries),
        'license': args.license,
        'sha256': hashlib.sha256(raw).hexdigest(),
    }
    manifest_path.write_text(
        json.dumps(
            manifest,
            ensure_ascii=False,
            indent=2,
        ),
        encoding='utf-8',
    )

    print(f'Created {data_path}')
    print(f'Created {manifest_path}')
    print(f'Entries: {len(entries)}; skipped: {skipped}')


if __name__ == '__main__':
    main()
