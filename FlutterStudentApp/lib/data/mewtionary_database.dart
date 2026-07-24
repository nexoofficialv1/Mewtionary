import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/adaptive_learning_models.dart';
import '../models/curriculum_models.dart';

class MewtionaryDatabase {
  MewtionaryDatabase._();

  static final MewtionaryDatabase instance = MewtionaryDatabase._();
  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    return openDatabase(
      p.join(root, 'mewtionary_v2_7.db'),
      version: 5,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await db.execute('PRAGMA journal_mode = WAL');
      },
      onCreate: (db, version) async {
        await _createCoreSchema(db);
        await _createAdaptiveSchema(db);
        await _createEngagementSchema(db);
        await _createTutorStudioSchema(db);
        await _createExamCoachSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createCoreSchema(db);
        if (oldVersion < 2) {
          await _createAdaptiveSchema(db);
        }
        if (oldVersion < 3) {
          await _createEngagementSchema(db);
        }
        if (oldVersion < 4) {
          await _createTutorStudioSchema(db);
        }
        if (oldVersion < 5) {
          await _createExamCoachSchema(db);
        }
      },
    );
  }

  Future<void> _createCoreSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dictionary_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pack_id TEXT NOT NULL,
        word TEXT NOT NULL,
        normalized_word TEXT NOT NULL,
        bangla TEXT NOT NULL,
        normalized_bangla TEXT NOT NULL,
        part_of_speech TEXT NOT NULL,
        pronunciation TEXT,
        definition TEXT,
        example TEXT,
        example_bangla TEXT,
        tags TEXT,
        UNIQUE(pack_id, normalized_word, normalized_bangla)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_dictionary_word '
      'ON dictionary_entries(normalized_word)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_dictionary_bangla '
      'ON dictionary_entries(normalized_bangla)',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dictionary_packs(
        pack_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        version TEXT NOT NULL,
        language_pair TEXT NOT NULL,
        entry_count INTEGER NOT NULL,
        license TEXT NOT NULL,
        sha256 TEXT NOT NULL,
        installed_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lesson_progress(
        lesson_id TEXT PRIMARY KEY,
        completed INTEGER NOT NULL DEFAULT 0,
        mastery REAL NOT NULL DEFAULT 0,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_opened_at TEXT,
        next_review_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS learning_events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_type TEXT NOT NULL,
        lesson_id TEXT,
        payload_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS parent_settings(
        setting_key TEXT PRIMARY KEY,
        setting_value TEXT NOT NULL
      )
    ''');
  }


  Future<void> _createEngagementSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reward_wallet(
        wallet_id INTEGER PRIMARY KEY CHECK(wallet_id = 1),
        xp INTEGER NOT NULL DEFAULT 0,
        coins INTEGER NOT NULL DEFAULT 0,
        streak INTEGER NOT NULL DEFAULT 0,
        last_activity_date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reward_events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_type TEXT NOT NULL,
        source_id TEXT NOT NULL,
        xp INTEGER NOT NULL,
        coins INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(source_type, source_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_attempts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        challenge_id TEXT NOT NULL,
        game_type TEXT NOT NULL,
        correct INTEGER NOT NULL,
        attempts INTEGER NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS listening_attempts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id TEXT NOT NULL,
        correct INTEGER NOT NULL,
        transcript TEXT,
        score REAL NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS story_adventure_progress(
        story_id TEXT PRIMARY KEY,
        completed INTEGER NOT NULL DEFAULT 0,
        page_index INTEGER NOT NULL DEFAULT 0,
        correct_answers INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS unlocked_badges(
        badge_id TEXT PRIMARY KEY,
        unlocked_at TEXT NOT NULL
      )
    ''');
    await db.insert(
      'reward_wallet',
      {
        'wallet_id': 1,
        'xp': 0,
        'coins': 0,
        'streak': 0,
        'last_activity_date': null,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }



  Future<void> _createExamCoachSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pronunciation_attempts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id TEXT NOT NULL,
        transcript TEXT NOT NULL,
        score REAL NOT NULL,
        successful INTEGER NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mock_exam_attempts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paper_id TEXT NOT NULL,
        earned_marks INTEGER NOT NULL,
        total_marks INTEGER NOT NULL,
        percentage REAL NOT NULL,
        passed INTEGER NOT NULL,
        answers_json TEXT NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS study_tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        route TEXT NOT NULL,
        planned_date TEXT NOT NULL,
        minutes INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        source TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_study_tasks_date '
      'ON study_tasks(planned_date)',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS issued_certificates(
        certificate_id TEXT PRIMARY KEY,
        issued_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTutorStudioSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS conversation_attempts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scenario_id TEXT NOT NULL,
        score INTEGER NOT NULL,
        max_score INTEGER NOT NULL,
        transcript_json TEXT NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS homework_drafts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS revision_attempts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        level_id TEXT NOT NULL,
        correct_answers INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        score REAL NOT NULL,
        skill_scores_json TEXT NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createAdaptiveSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_profile(
        profile_id INTEGER PRIMARY KEY CHECK(profile_id = 1),
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        level_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS diagnostic_attempts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score REAL NOT NULL,
        correct_answers INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        recommended_level_id TEXT NOT NULL,
        skill_scores_json TEXT NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS writing_attempts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prompt_id TEXT NOT NULL,
        prompt_text TEXT NOT NULL,
        stroke_count INTEGER NOT NULL,
        self_score INTEGER NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_plan_completions(
        plan_date TEXT NOT NULL,
        item_id TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        PRIMARY KEY(plan_date, item_id)
      )
    ''');
  }

  Future<void> upsertProgress(LessonProgressRecord record) async {
    final db = await database;
    await db.insert(
      'lesson_progress',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, LessonProgressRecord>> loadProgress() async {
    final db = await database;
    final rows = await db.query('lesson_progress');
    return {
      for (final row in rows)
        row['lesson_id'] as String: LessonProgressRecord.fromMap(row),
    };
  }

  Future<void> logEvent({
    required String type,
    String? lessonId,
    required Map<String, dynamic> payload,
  }) async {
    final db = await database;
    await db.insert('learning_events', {
      'event_type': type,
      'lesson_id': lessonId,
      'payload_json': jsonEncode(payload),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> recentEvents({
    DateTime? since,
    int limit = 200,
  }) async {
    final db = await database;
    if (since == null) {
      return db.query(
        'learning_events',
        orderBy: 'created_at DESC',
        limit: limit,
      );
    }
    return db.query(
      'learning_events',
      where: 'created_at >= ?',
      whereArgs: [since.toIso8601String()],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  Future<void> setParentSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'parent_settings',
      {'setting_key': key, 'setting_value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getParentSetting(String key) async {
    final db = await database;
    final rows = await db.query(
      'parent_settings',
      where: 'setting_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['setting_value'] as String;
  }

  Future<StudentProfile?> loadStudentProfile() async {
    final db = await database;
    final rows = await db.query(
      'student_profile',
      where: 'profile_id = 1',
      limit: 1,
    );
    return rows.isEmpty ? null : StudentProfile.fromMap(rows.first);
  }

  Future<void> saveStudentProfile(StudentProfile profile) async {
    final db = await database;
    await db.insert(
      'student_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveDiagnosticResult(
    DiagnosticResult result,
  ) async {
    final db = await database;
    final map = result.toMap();
    await db.insert('diagnostic_attempts', {
      'score': map['score'],
      'correct_answers': map['correct_answers'],
      'total_questions': map['total_questions'],
      'recommended_level_id': map['recommended_level_id'],
      'skill_scores_json': jsonEncode(map['skill_scores_json']),
      'completed_at': map['completed_at'],
    });
  }

  Future<Map<String, Object?>?> latestDiagnostic() async {
    final db = await database;
    final rows = await db.query(
      'diagnostic_attempts',
      orderBy: 'completed_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> saveWritingAttempt({
    required String promptId,
    required String promptText,
    required int strokeCount,
    required int selfScore,
  }) async {
    final db = await database;
    await db.insert('writing_attempts', {
      'prompt_id': promptId,
      'prompt_text': promptText,
      'stroke_count': strokeCount,
      'self_score': selfScore,
      'completed_at': DateTime.now().toIso8601String(),
    });
    await logEvent(
      type: 'writing_completed',
      payload: {
        'promptId': promptId,
        'strokeCount': strokeCount,
        'selfScore': selfScore,
      },
    );
  }

  Future<List<Map<String, Object?>>> recentWritingAttempts({
    int limit = 20,
  }) async {
    final db = await database;
    return db.query(
      'writing_attempts',
      orderBy: 'completed_at DESC',
      limit: limit,
    );
  }

  Future<void> markDailyPlanItemComplete(String itemId) async {
    final db = await database;
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day)
        .toIso8601String()
        .split('T')
        .first;
    await db.insert(
      'daily_plan_completions',
      {
        'plan_date': date,
        'item_id': itemId,
        'completed_at': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await logEvent(
      type: 'daily_plan_item_completed',
      payload: {'itemId': itemId},
    );
  }

  Future<Set<String>> todayCompletedPlanItems() async {
    final db = await database;
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day)
        .toIso8601String()
        .split('T')
        .first;
    final rows = await db.query(
      'daily_plan_completions',
      columns: ['item_id'],
      where: 'plan_date = ?',
      whereArgs: [date],
    );
    return rows.map((row) => row['item_id'] as String).toSet();
  }

  Future<Map<String, Object?>?> loadRewardWallet() async {
    final db = await database;
    final rows = await db.query(
      'reward_wallet',
      where: 'wallet_id = 1',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<bool> addReward({
    required String sourceType,
    required String sourceId,
    required int xp,
    required int coins,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final inserted = await txn.insert(
        'reward_events',
        {
          'source_type': sourceType,
          'source_id': sourceId,
          'xp': xp,
          'coins': coins,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      if (inserted <= 0) return false;

      final rows = await txn.query(
        'reward_wallet',
        where: 'wallet_id = 1',
        limit: 1,
      );
      final current = rows.isEmpty
          ? <String, Object?>{
              'xp': 0,
              'coins': 0,
              'streak': 0,
              'last_activity_date': null,
            }
          : rows.first;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final previous = DateTime.tryParse(
        current['last_activity_date'] as String? ?? '',
      );
      var streak = current['streak'] as int? ?? 0;

      if (previous == null) {
        streak = 1;
      } else {
        final previousDay = DateTime(
          previous.year,
          previous.month,
          previous.day,
        );
        final difference = today.difference(previousDay).inDays;
        if (difference == 1) {
          streak += 1;
        } else if (difference > 1) {
          streak = 1;
        }
      }

      await txn.insert(
        'reward_wallet',
        {
          'wallet_id': 1,
          'xp': (current['xp'] as int? ?? 0) + xp,
          'coins': (current['coins'] as int? ?? 0) + coins,
          'streak': streak,
          'last_activity_date': today.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    });
  }

  Future<void> saveGameAttempt({
    required String challengeId,
    required String gameType,
    required bool correct,
    required int attempts,
  }) async {
    final db = await database;
    await db.insert('game_attempts', {
      'challenge_id': challengeId,
      'game_type': gameType,
      'correct': correct ? 1 : 0,
      'attempts': attempts,
      'completed_at': DateTime.now().toIso8601String(),
    });
    await logEvent(
      type: 'game_completed',
      payload: {
        'challengeId': challengeId,
        'gameType': gameType,
        'correct': correct,
        'attempts': attempts,
      },
    );
  }

  Future<int> successfulGameCount() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM game_attempts WHERE correct = 1',
    );
    return rows.first['total'] as int? ?? 0;
  }

  Future<void> saveListeningAttempt({
    required String exerciseId,
    required bool correct,
    required String transcript,
    required double score,
  }) async {
    final db = await database;
    await db.insert('listening_attempts', {
      'exercise_id': exerciseId,
      'correct': correct ? 1 : 0,
      'transcript': transcript,
      'score': score,
      'completed_at': DateTime.now().toIso8601String(),
    });
    await logEvent(
      type: 'listening_completed',
      payload: {
        'exerciseId': exerciseId,
        'correct': correct,
        'score': score,
      },
    );
  }

  Future<int> successfulListeningCount() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total '
      'FROM listening_attempts WHERE correct = 1',
    );
    return rows.first['total'] as int? ?? 0;
  }

  Future<void> saveAdventureProgress({
    required String storyId,
    required int pageIndex,
    required bool completed,
    required int correctAnswers,
  }) async {
    final db = await database;
    await db.insert(
      'story_adventure_progress',
      {
        'story_id': storyId,
        'completed': completed ? 1 : 0,
        'page_index': pageIndex,
        'correct_answers': correctAnswers,
        'completed_at':
            completed ? DateTime.now().toIso8601String() : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (completed) {
      await logEvent(
        type: 'story_adventure_completed',
        payload: {
          'storyId': storyId,
          'correctAnswers': correctAnswers,
        },
      );
    }
  }

  Future<Map<String, Object?>?> adventureProgress(
    String storyId,
  ) async {
    final db = await database;
    final rows = await db.query(
      'story_adventure_progress',
      where: 'story_id = ?',
      whereArgs: [storyId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> completedAdventureCount() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total '
      'FROM story_adventure_progress WHERE completed = 1',
    );
    return rows.first['total'] as int? ?? 0;
  }

  Future<void> unlockBadge(String badgeId) async {
    final db = await database;
    await db.insert(
      'unlocked_badges',
      {
        'badge_id': badgeId,
        'unlocked_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Map<String, DateTime>> loadUnlockedBadges() async {
    final db = await database;
    final rows = await db.query('unlocked_badges');
    return {
      for (final row in rows)
        row['badge_id'] as String: DateTime.parse(
          row['unlocked_at'] as String,
        ),
    };
  }


  Future<void> saveConversationAttempt({
    required String scenarioId,
    required int score,
    required int maxScore,
    required List<Map<String, dynamic>> transcript,
  }) async {
    final db = await database;
    await db.insert('conversation_attempts', {
      'scenario_id': scenarioId,
      'score': score,
      'max_score': maxScore,
      'transcript_json': jsonEncode(transcript),
      'completed_at': DateTime.now().toIso8601String(),
    });
    await logEvent(
      type: 'conversation_completed',
      payload: {
        'scenarioId': scenarioId,
        'score': score,
        'maxScore': maxScore,
      },
    );
  }

  Future<int> completedConversationCount() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM conversation_attempts',
    );
    return rows.first['total'] as int? ?? 0;
  }

  Future<int> saveHomeworkDraft({
    int? id,
    required String templateId,
    required String title,
    required String content,
  }) async {
    final db = await database;
    final values = {
      'template_id': templateId,
      'title': title,
      'content': content,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (id == null) {
      final inserted = await db.insert('homework_drafts', values);
      await logEvent(
        type: 'homework_draft_saved',
        payload: {'templateId': templateId},
      );
      return inserted;
    }
    await db.update(
      'homework_drafts',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
    return id;
  }

  Future<List<Map<String, Object?>>> loadHomeworkDrafts() async {
    final db = await database;
    return db.query(
      'homework_drafts',
      orderBy: 'updated_at DESC',
    );
  }

  Future<void> deleteHomeworkDraft(int id) async {
    final db = await database;
    await db.delete(
      'homework_drafts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveRevisionAttempt({
    required String levelId,
    required int correctAnswers,
    required int totalQuestions,
    required Map<String, double> skillScores,
  }) async {
    final db = await database;
    final score = totalQuestions == 0
        ? 0.0
        : correctAnswers / totalQuestions;
    await db.insert('revision_attempts', {
      'level_id': levelId,
      'correct_answers': correctAnswers,
      'total_questions': totalQuestions,
      'score': score,
      'skill_scores_json': jsonEncode(skillScores),
      'completed_at': DateTime.now().toIso8601String(),
    });
    await logEvent(
      type: 'revision_quiz_completed',
      payload: {
        'levelId': levelId,
        'correct': correctAnswers,
        'total': totalQuestions,
        'score': score,
      },
    );
  }

  Future<Map<String, Object?>?> latestRevisionAttempt() async {
    final db = await database;
    final rows = await db.query(
      'revision_attempts',
      orderBy: 'completed_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }


  Future<int> completedRevisionCount() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM revision_attempts',
    );
    return rows.first['total'] as int? ?? 0;
  }


  Future<void> savePronunciationAttempt({
    required String exerciseId,
    required String transcript,
    required double score,
    required bool successful,
  }) async {
    final db = await database;
    await db.insert('pronunciation_attempts', {
      'exercise_id': exerciseId,
      'transcript': transcript,
      'score': score,
      'successful': successful ? 1 : 0,
      'completed_at': DateTime.now().toIso8601String(),
    });
    await logEvent(
      type: 'pronunciation_completed',
      payload: {
        'exerciseId': exerciseId,
        'score': score,
        'successful': successful,
      },
    );
  }

  Future<int> successfulPronunciationCount() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(DISTINCT exercise_id) AS total '
      'FROM pronunciation_attempts WHERE successful = 1',
    );
    return rows.first['total'] as int? ?? 0;
  }

  Future<void> saveMockExamAttempt({
    required String paperId,
    required int earnedMarks,
    required int totalMarks,
    required Map<String, String> answers,
  }) async {
    final db = await database;
    final percentage =
        totalMarks == 0 ? 0.0 : earnedMarks / totalMarks;
    await db.insert('mock_exam_attempts', {
      'paper_id': paperId,
      'earned_marks': earnedMarks,
      'total_marks': totalMarks,
      'percentage': percentage,
      'passed': percentage >= .4 ? 1 : 0,
      'answers_json': jsonEncode(answers),
      'completed_at': DateTime.now().toIso8601String(),
    });
    await logEvent(
      type: 'mock_exam_completed',
      payload: {
        'paperId': paperId,
        'earnedMarks': earnedMarks,
        'totalMarks': totalMarks,
        'percentage': percentage,
      },
    );
  }

  Future<int> passedMockExamCount() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(DISTINCT paper_id) AS total '
      'FROM mock_exam_attempts WHERE passed = 1',
    );
    return rows.first['total'] as int? ?? 0;
  }

  Future<int> addStudyTask({
    required String title,
    required String subtitle,
    required String route,
    required DateTime plannedDate,
    required int minutes,
    required String source,
  }) async {
    final db = await database;
    return db.insert('study_tasks', {
      'title': title,
      'subtitle': subtitle,
      'route': route,
      'planned_date': plannedDate.toIso8601String(),
      'minutes': minutes,
      'completed': 0,
      'source': source,
    });
  }

  Future<List<Map<String, Object?>>> loadStudyTasks({
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await database;
    return db.query(
      'study_tasks',
      where: 'planned_date >= ? AND planned_date < ?',
      whereArgs: [
        from.toIso8601String(),
        to.toIso8601String(),
      ],
      orderBy: 'planned_date ASC, id ASC',
    );
  }

  Future<void> setStudyTaskCompleted({
    required int id,
    required bool completed,
  }) async {
    final db = await database;
    await db.update(
      'study_tasks',
      {'completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (completed) {
      await logEvent(
        type: 'study_task_completed',
        payload: {'taskId': id},
      );
    }
  }

  Future<void> deleteStudyTask(int id) async {
    final db = await database;
    await db.delete(
      'study_tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> completedStudyTaskCount() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM study_tasks '
      'WHERE completed = 1',
    );
    return rows.first['total'] as int? ?? 0;
  }

  Future<void> issueCertificate(String certificateId) async {
    final db = await database;
    await db.insert(
      'issued_certificates',
      {
        'certificate_id': certificateId,
        'issued_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Set<String>> issuedCertificateIds() async {
    final db = await database;
    final rows = await db.query('issued_certificates');
    return rows
        .map((row) => row['certificate_id'] as String)
        .toSet();
  }

}
