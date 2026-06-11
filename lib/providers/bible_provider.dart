import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bible_book.dart';
import '../models/verse.dart';
import '../services/bible_db_service.dart';

// Books list provider — async로 DB 초기화 보장
final booksProvider = FutureProvider<List<BibleBook>>((ref) async {
  await BibleDbService.database; // DB 초기화 대기
  return BibleDbService.books;
});

// Chapter content provider
final chapterProvider =
    FutureProvider.family<List<String>, ChapterKey>((ref, key) async {
  return BibleDbService.getChapter(key.volume, key.chapter);
});

class ChapterKey {
  final int volume;
  final int chapter;

  const ChapterKey(this.volume, this.chapter);

  @override
  bool operator ==(Object other) =>
      other is ChapterKey &&
      other.volume == volume &&
      other.chapter == chapter;

  @override
  int get hashCode => volume.hashCode ^ chapter.hashCode;
}

// Keyword search provider
class KeywordSearchNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  KeywordSearchNotifier() : super([]);

  Future<void> search(String keyword) async {
    if (keyword.trim().length < 2) {
      state = [];
      return;
    }
    state = await BibleDbService.searchKeyword(keyword);
  }

  void clear() => state = [];
}

final keywordSearchProvider = StateNotifierProvider<KeywordSearchNotifier,
    List<Map<String, dynamic>>>((ref) {
  return KeywordSearchNotifier();
});

// Daily verse provider — 날짜 기반으로 선별된 구절을 본문과 함께 제공
final dailyVerseProvider = FutureProvider<Verse?>((ref) async {
  await BibleDbService.database; // DB 초기화 대기

  // Curated daily verse list
  final dailyVerses = [
    {'vl': 19, 'cn': 23, 'v': 1, 'end': 3},
    {'vl': 43, 'cn': 3, 'v': 16, 'end': 16},
    {'vl': 45, 'cn': 8, 'v': 28, 'end': 28},
    {'vl': 23, 'cn': 41, 'v': 10, 'end': 10},
    {'vl': 20, 'cn': 3, 'v': 5, 'end': 6},
    {'vl': 19, 'cn': 46, 'v': 10, 'end': 10},
    {'vl': 50, 'cn': 4, 'v': 13, 'end': 13},
    {'vl': 19, 'cn': 27, 'v': 1, 'end': 1},
    {'vl': 40, 'cn': 11, 'v': 28, 'end': 30},
    {'vl': 46, 'cn': 13, 'v': 4, 'end': 7},
    {'vl': 19, 'cn': 119, 'v': 105, 'end': 105},
    {'vl': 23, 'cn': 40, 'v': 31, 'end': 31},
    {'vl': 45, 'cn': 12, 'v': 12, 'end': 12},
    {'vl': 49, 'cn': 2, 'v': 8, 'end': 9},
    {'vl': 19, 'cn': 91, 'v': 1, 'end': 2},
    {'vl': 58, 'cn': 11, 'v': 1, 'end': 1},
    {'vl': 19, 'cn': 37, 'v': 4, 'end': 5},
    {'vl': 45, 'cn': 8, 'v': 38, 'end': 39},
    {'vl': 24, 'cn': 29, 'v': 11, 'end': 11},
    {'vl': 43, 'cn': 14, 'v': 27, 'end': 27},
    {'vl': 19, 'cn': 121, 'v': 1, 'end': 2},
    {'vl': 40, 'cn': 6, 'v': 33, 'end': 33},
    {'vl': 48, 'cn': 2, 'v': 20, 'end': 20},
    {'vl': 62, 'cn': 4, 'v': 18, 'end': 18},
    {'vl': 19, 'cn': 34, 'v': 18, 'end': 18},
    {'vl': 52, 'cn': 5, 'v': 16, 'end': 18},
    {'vl': 59, 'cn': 1, 'v': 2, 'end': 3},
    {'vl': 19, 'cn': 139, 'v': 13, 'end': 14},
    {'vl': 40, 'cn': 28, 'v': 20, 'end': 20},
    {'vl': 23, 'cn': 43, 'v': 18, 'end': 19},
    {'vl': 19, 'cn': 103, 'v': 1, 'end': 2},
  ];

  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 0)).inDays;
  final idx = dayOfYear % dailyVerses.length;
  final entry = dailyVerses[idx];

  final vl = entry['vl'] as int;
  final cn = entry['cn'] as int;
  final v = entry['v'] as int;
  final end = entry['end'] as int;

  final texts = await BibleDbService.getVerseTexts(vl, cn, v, end);
  if (texts.isEmpty) return null;

  final bookName = BibleDbService.getBookName(vl);
  final reference =
      v == end ? '$bookName $cn:$v' : '$bookName $cn:$v-$end';

  return Verse(reference: reference, text: texts.join(' '));
});
