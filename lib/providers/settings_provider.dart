import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final double fontSize;
  final Set<String> readChapters; // "volume:chapter" format

  const SettingsState({
    this.fontSize = 16.0,
    this.readChapters = const {},
  });

  SettingsState copyWith({
    double? fontSize,
    Set<String>? readChapters,
  }) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      readChapters: readChapters ?? this.readChapters,
    );
  }

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
    state = SettingsState(fontSize: fontSize, readChapters: readChapters);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', state.fontSize);
    await prefs.setString(
        'readChapters', json.encode(state.readChapters.toList()));
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size.clamp(12.0, 28.0));
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
