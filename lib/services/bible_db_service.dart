import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/bible_book.dart';

class BibleDbService {
  static Database? _db;
  static final Map<String, String> _abbrToName = {};
  static final Map<String, String> _nameToVl = {};
  static List<BibleBook>? _books;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'bible.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE books (
            volume INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            abbr TEXT NOT NULL,
            chapter_count INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE verses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            volume INTEGER NOT NULL,
            chapter INTEGER NOT NULL,
            verse INTEGER NOT NULL,
            text TEXT NOT NULL,
            UNIQUE(volume, chapter, verse)
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_verses_vol_ch ON verses(volume, chapter)');
        await db.execute(
            'CREATE INDEX idx_verses_text ON verses(text)');

        await _importBibleData(db);
      },
    );

    await _loadLookups(db);
    return db;
  }

  static Future<void> _importBibleData(Database db) async {
    final jsonStr = await rootBundle.loadString('assets/bible.json');
    final Map<String, dynamic> data = json.decode(jsonStr);

    final batch = db.batch();
    for (final entry in data.entries) {
      final vl = int.parse(entry.key);
      final book = entry.value as Map<String, dynamic>;
      final name = book['name'] as String;
      final abbr = book['abbr'] as String;
      final chapters = book['chapters'] as Map<String, dynamic>;

      batch.insert('books', {
        'volume': vl,
        'name': name,
        'abbr': abbr,
        'chapter_count': chapters.length,
      });

      for (final chEntry in chapters.entries) {
        final ch = int.parse(chEntry.key);
        final verses = chEntry.value as List<dynamic>;
        for (int i = 0; i < verses.length; i++) {
          batch.insert('verses', {
            'volume': vl,
            'chapter': ch,
            'verse': i + 1,
            'text': verses[i] as String,
          });
        }
      }
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _loadLookups(Database db) async {
    final rows = await db.query('books');
    _books = [];
    for (final row in rows) {
      final vl = row['volume'] as int;
      final name = row['name'] as String;
      final abbr = row['abbr'] as String;
      _nameToVl[name] = vl.toString();
      _nameToVl[abbr] = vl.toString();
      if (abbr != name) _abbrToName[abbr] = name;
      _books!.add(BibleBook(
        volume: vl,
        name: name,
        abbr: abbr,
        chapterCount: row['chapter_count'] as int,
        isOldTestament: vl <= 39,
      ));
    }
  }

  static List<BibleBook> get books => _books ?? [];

  static String abbrToFullName(String name) => _abbrToName[name] ?? name;

  static Future<List<String>> getChapter(int volume, int chapter) async {
    final db = await database;
    final rows = await db.query(
      'verses',
      columns: ['text'],
      where: 'volume = ? AND chapter = ?',
      whereArgs: [volume, chapter],
      orderBy: 'verse ASC',
    );
    return rows.map((r) => r['text'] as String).toList();
  }

  static Future<String?> getVerse(
      String bookName, int chapter, int verse) async {
    final vl = _nameToVl[bookName];
    if (vl == null) return null;
    final db = await database;
    final rows = await db.query(
      'verses',
      columns: ['text'],
      where: 'volume = ? AND chapter = ? AND verse = ?',
      whereArgs: [int.parse(vl), chapter, verse],
    );
    if (rows.isEmpty) return null;
    return rows.first['text'] as String;
  }

  static Future<String?> getVerseRange(
      String bookName, int chapter, int startVerse, int endVerse) async {
    final vl = _nameToVl[bookName];
    if (vl == null) return null;
    final db = await database;
    final rows = await db.query(
      'verses',
      columns: ['verse', 'text'],
      where: 'volume = ? AND chapter = ? AND verse >= ? AND verse <= ?',
      whereArgs: [int.parse(vl), chapter, startVerse, endVerse],
      orderBy: 'verse ASC',
    );
    if (rows.isEmpty) return null;
    return rows
        .map((r) => '[${r['verse']}절] ${r['text']}')
        .join('\n');
  }

  static Future<List<Map<String, dynamic>>> searchKeyword(
      String keyword, {int limit = 50}) async {
    if (keyword.trim().length < 2) return [];
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT b.name, v.chapter, v.verse, v.text
      FROM verses v
      JOIN books b ON b.volume = v.volume
      WHERE v.text LIKE ?
      LIMIT ?
    ''', ['%${keyword.trim()}%', limit]);

    return rows.map((r) {
      final name = r['name'] as String;
      final ch = r['chapter'] as int;
      final vs = r['verse'] as int;
      return {
        'reference': '$name $ch:$vs',
        'text': r['text'] as String,
      };
    }).toList();
  }

  /// Get volume number from book name
  static int? getVolume(String bookName) {
    final vl = _nameToVl[bookName];
    return vl != null ? int.tryParse(vl) : null;
  }

  /// Get book name from volume number
  static String getBookName(int volume) {
    final book = _books?.firstWhere(
      (b) => b.volume == volume,
      orElse: () => BibleBook(
          volume: 0, name: '', abbr: '', chapterCount: 0, isOldTestament: true),
    );
    return book?.name ?? '';
  }

  /// Get chapter count for a book
  static int getChapterCount(int volume) {
    final book = _books?.firstWhere(
      (b) => b.volume == volume,
      orElse: () => BibleBook(
          volume: 0, name: '', abbr: '', chapterCount: 0, isOldTestament: true),
    );
    return book?.chapterCount ?? 0;
  }

  /// Get verse count for a chapter
  static Future<int> getVerseCount(int volume, int chapter) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM verses WHERE volume = ? AND chapter = ?',
      [volume, chapter],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
