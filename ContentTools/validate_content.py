#!/usr/bin/env python3
from pathlib import Path
import hashlib
import json
import sys

root = Path(__file__).resolve().parents[1]
content = root / 'FlutterStudentApp' / 'assets' / 'content'
packs = root / 'FlutterStudentApp' / 'assets' / 'packs'
errors = []

curriculum_files = sorted(content.glob('curriculum_*.json'))
if len(curriculum_files) != 10:
    errors.append(
        f'Expected 10 curriculum files, found {len(curriculum_files)}'
    )

for path in curriculum_files:
    try:
        data = json.loads(path.read_text(encoding='utf-8'))
        assert data['schemaVersion'] == 1
        assert data['units']
    except Exception as exc:
        errors.append(f'{path.name}: {exc}')

try:
    manifest = json.loads(
        (packs / 'starter_dictionary_manifest.json')
        .read_text(encoding='utf-8')
    )
    raw = (
        packs / 'starter_dictionary_entries.jsonl'
    ).read_bytes()
    assert hashlib.sha256(raw).hexdigest() == manifest['sha256']
except Exception as exc:
    errors.append(f'starter_dictionary_pack: {exc}')

specs = {
    'diagnostic_questions.json': ('questions', 10),
    'writing_prompts.json': ('prompts', 10),
    'mini_games.json': ('challenges', 10),
    'listening_exercises.json': ('exercises', 10),
    'story_adventures.json': ('stories', 3),
    'badges.json': ('badges', 12),
    'conversation_scenarios.json': ('scenarios', 4),
    'homework_templates.json': ('templates', 5),
    'revision_questions.json': ('questions', 18),
    'pronunciation_lessons.json': ('exercises', 12),
    'mock_exams.json': ('papers', 5),
    'certificates.json': ('certificates', 5),
}

for filename, (key, minimum) in specs.items():
    try:
        data = json.loads(
            (content / filename).read_text(encoding='utf-8')
        )
        assert data['schemaVersion'] == 1
        assert len(data[key]) >= minimum
    except Exception as exc:
        errors.append(f'{filename}: {exc}')

try:
    data = json.loads(
        (content / 'pronunciation_lessons.json')
        .read_text(encoding='utf-8')
    )
    for item in data['exercises']:
        assert item['id']
        assert item['target']
        assert item['syllables']
        assert item['focusSounds']
        assert item['mouthTip']
except Exception as exc:
    errors.append(f'pronunciation_detail: {exc}')

try:
    data = json.loads(
        (content / 'mock_exams.json')
        .read_text(encoding='utf-8')
    )
    allowed = {'mcq', 'fillBlank', 'rearrange', 'shortAnswer'}
    for paper in data['papers']:
        assert paper['id']
        assert paper['durationMinutes'] > 0
        assert paper['questions']
        for question in paper['questions']:
            assert question['type'] in allowed
            assert question['marks'] > 0
            assert question['answer']
            if question['type'] == 'mcq':
                assert question['options']
except Exception as exc:
    errors.append(f'mock_exam_detail: {exc}')

try:
    data = json.loads(
        (content / 'certificates.json')
        .read_text(encoding='utf-8')
    )
    allowed = {'xp', 'pronunciation', 'exam', 'studyTasks'}
    for item in data['certificates']:
        assert item['id']
        assert item['ruleType'] in allowed
        assert item['threshold'] > 0
except Exception as exc:
    errors.append(f'certificate_detail: {exc}')

if errors:
    print('\n'.join(errors))
    sys.exit(1)

print('Mewtionary v2.7 content validated.')
