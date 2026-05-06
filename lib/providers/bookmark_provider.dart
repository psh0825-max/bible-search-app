import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/bookmark.dart';

class BookmarkNotifier extends StateNotifier<List<Bookmark>> {
  BookmarkNotifier() : super([]) {
    _loadBookmarks();
  }

  static const _key = 'bookmarks';
  static const _uuid = Uuid();

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      final List<dynamic> list = json.decode(jsonStr);
      state = list.map((e) => Bookmark.fromJson(e)).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(state.map((b) => b.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }

  Future<void> addBookmark({
    required String reference,
    required String text,
    String reason = '',
    String mood = 'faith',
  }) async {
    // Check duplicate
    if (state.any((b) => b.reference == reference)) return;

    final bookmark = Bookmark(
      id: _uuid.v4(),
      reference: reference,
      text: text,
      reason: reason,
      mood: mood,
      createdAt: DateTime.now(),
    );
    state = [bookmark, ...state];
    await _save();
  }

  Future<void> removeBookmark(String id) async {
    state = state.where((b) => b.id != id).toList();
    await _save();
  }

  Future<void> updateNote(String id, String note) async {
    state = state.map((b) {
      if (b.id == id) return b.copyWith(note: note);
      return b;
    }).toList();
    await _save();
  }

  Future<void> updateHighlight(String id, int color) async {
    state = state.map((b) {
      if (b.id == id) return b.copyWith(highlightColor: color);
      return b;
    }).toList();
    await _save();
  }

  bool isBookmarked(String reference) {
    return state.any((b) => b.reference == reference);
  }
}

final bookmarkProvider =
    StateNotifierProvider<BookmarkNotifier, List<Bookmark>>((ref) {
  return BookmarkNotifier();
});
