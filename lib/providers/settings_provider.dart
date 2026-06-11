import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final double fontSize;
  final Set<String> readChapters; // "volume:chapter" format
  final int? lastReadVolume;
  final int? lastReadChapter;

  const SettingsState({
    this.fontSize = 16.0,
    this.readChapters = const {},
    this.lastReadVolume,
    this.lastReadChapter,
  });

  SettingsState copyWith({
    double? fontSize,
    Set<String>? readChapters,
    int? lastReadVolume,
    int? lastReadChapter,
  }) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      readChapters: readChapters ?? this.readChapters,
      lastReadVolume: lastReadVolume ?? this.lastReadVolume,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
    );
  }

  bool get hasLastRead => lastReadVolume != null && lastReadChapter != null;

  double get readingProgress {
    // Total chapters in Bible: 1189
    return readChapters.length / 1189;
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble('fontSize') ?? 16.0;
    final readChaptersJson = prefs.getString('readChapters');
    Set<String> readChapters = {};
    if (readChaptersJson != null) {
      readChapters = Set<String>.from(json.decode(readChaptersJson));
    }
    state = SettingsState(
      fontSize: fontSize,
      readChapters: readChapters,
      lastReadVolume: prefs.getInt('lastReadVolume'),
      lastReadChapter: prefs.getInt('lastReadChapter'),
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', state.fontSize);
    await prefs.setString(
        'readChapters', json.encode(state.readChapters.toList()));
    if (state.lastReadVolume != null) {
      await prefs.setInt('lastReadVolume', state.lastReadVolume!);
    }
    if (state.lastReadChapter != null) {
      await prefs.setInt('lastReadChapter', state.lastReadChapter!);
    }
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size.clamp(12.0, 28.0));
    _save();
  }

  /// 마지막으로 펼친 장 기록 — 성경 탭의 "이어 읽기" 카드에 사용.
  void setLastRead(int volume, int chapter) {
    if (state.lastReadVolume == volume && state.lastReadChapter == chapter) {
      return;
    }
    state = state.copyWith(lastReadVolume: volume, lastReadChapter: chapter);
    _save();
  }

  void markChapterRead(int volume, int chapter) {
    final key = '$volume:$chapter';
    final newSet = {...state.readChapters, key};
    state = state.copyWith(readChapters: newSet);
    _save();
  }

  void unmarkChapterRead(int volume, int chapter) {
    final key = '$volume:$chapter';
    final newSet = {...state.readChapters}..remove(key);
    state = state.copyWith(readChapters: newSet);
    _save();
  }

  bool isChapterRead(int volume, int chapter) {
    return state.readChapters.contains('$volume:$chapter');
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
