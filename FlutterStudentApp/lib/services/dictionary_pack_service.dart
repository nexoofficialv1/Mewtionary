import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../data/mewtionary_database.dart';
import '../models/curriculum_models.dart';

class DictionaryPackImportResult {
  const DictionaryPackImportResult({
    required this.packId,
    required this.imported,
    required this.skipped,
  });

  final String packId;
  final int imported;
  final int skipped;
}

class DictionaryPackService {
  DictionaryPackService({MewtionaryDatabase? database})
      : _database = database ?? MewtionaryDatabase.instance;

  final MewtionaryDatabase _database;

  Future<DictionaryPackImportResult> installBundledPack() async {
    final manifest = await rootBundle.loadString(
      'assets/packs/starter_dictionary_manifest.json',
    );
    final data = await rootBundle.load(
      'assets/packs/starter_dictionary_entries.jsonl',
    );
    return installBytes(
      manifestJson: manifest,
      jsonlBytes: data.buffer.asUint8List(),
    );
  }

  Future<DictionaryPackImportResult> installBytes({
    required String manifestJson,
    required Uint8List jsonlBytes,
  }) async {
    final manifest = DictionaryPackManifest.fromJson(
      jsonDecode(manifestJson) as Map<String, dynamic>,
    );

    final actualHash = sha256.convert(jsonlBytes).toString();
    if (actualHash != manifest.sha256) {
      throw FormatException(
        'Checksum mismatch: expected ${manifest.sha256}, '
        'received $actualHash.',
      );
    }
    if (manifest.languagePair != 'en-bn') {
      throw const FormatException(
        'Only English–Bangla packs are accepted.',
      );
    }

    final db = await _database.database;
    var imported = 0;
    var skipped = 0;

    await db.transaction((txn) async {
      var batch = txn.batch();
      var batchSize = 0;

      for (final line in const LineSplitter()
          .convert(utf8.decode(jsonlBytes))) {
        if (line.trim().isEmpty) continue;
        final entry = jsonDecode(line) as Map<String, dynamic>;
        final word = (entry['word'] as String? ?? '').trim();
        final bangla = (entry['bangla'] as String? ?? '').trim();
        if (word.isEmpty || bangla.isEmpty) {
          skipped++;
          continue;
        }

        batch.insert(
          'dictionary_entries',
          {
            'pack_id': manifest.packId,
            'word': word,
            'normalized_word': normalizeEnglish(word),
            'bangla': bangla,
            'normalized_bangla': normalizeBangla(bangla),
            'part_of_speech':
                entry['partOfSpeech'] as String? ?? 'unknown',
            'pronunciation': entry['pronunciation'] as String? ?? '',
            'definition': entry['definition'] as String? ?? '',
            'example': entry['example'] as String? ?? '',
            'example_bangla': entry['exampleBangla'] as String? ?? '',
            'tags': jsonEncode(entry['tags'] ?? const []),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        imported++;
        batchSize++;

        if (batchSize >= 500) {
          await batch.commit(noResult: true);
          batch = txn.batch();
          batchSize = 0;
        }
      }

      if (batchSize > 0) {
        await batch.commit(noResult: true);
      }

      await txn.insert(
        'dictionary_packs',
        {
          'pack_id': manifest.packId,
          'name': manifest.name,
          'version': manifest.version,
          'language_pair': manifest.languagePair,
          'entry_count': manifest.entryCount,
          'license': manifest.license,
          'sha256': manifest.sha256,
          'installed_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    return DictionaryPackImportResult(
      packId: manifest.packId,
      imported: imported,
      skipped: skipped,
    );
  }

  Future<List<Map<String, Object?>>> search(
    String query, {
    int limit = 50,
  }) async {
    final db = await _database.database;
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return db.query(
        'dictionary_entries',
        orderBy: 'word COLLATE NOCASE',
        limit: limit,
      );
    }

    final english = normalizeEnglish(trimmed);
    final bangla = normalizeBangla(trimmed);

    return db.rawQuery(
      '''
      SELECT *,
        CASE
          WHEN normalized_word = ? THEN 0
          WHEN normalized_bangla = ? THEN 0
          WHEN normalized_word LIKE ? THEN 1
          WHEN normalized_bangla LIKE ? THEN 1
          ELSE 2
        END AS search_rank
      FROM dictionary_entries
      WHERE normalized_word LIKE ?
         OR normalized_bangla LIKE ?
         OR definition LIKE ?
      ORDER BY search_rank, LENGTH(word), word COLLATE NOCASE
      LIMIT ?
      ''',
      [
        english,
        bangla,
        '$english%',
        '$bangla%',
        '%$english%',
        '%$bangla%',
        '%$trimmed%',
        limit,
      ],
    );
  }

  Future<int> installedEntryCount() async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM dictionary_entries',
    );
    return result.first['total'] as int? ?? 0;
  }

  Future<List<Map<String, Object?>>> installedPacks() async {
    final db = await _database.database;
    return db.query(
      'dictionary_packs',
      orderBy: 'installed_at DESC',
    );
  }

  static String normalizeEnglish(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9'\-\s]"), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String normalizeBangla(String value) {
    return value
        .replaceAll('\u200C', '')
        .replaceAll('\u200D', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
