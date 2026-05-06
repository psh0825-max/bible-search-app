import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verse.dart';
import '../services/gemini_service.dart';

enum SearchStatus { idle, loading, success, error }

class SearchState {
  final List<Verse> verses;
  final SearchStatus status;
  final String errorMessage;
  final String query;

  const SearchState({
    this.verses = const [],
    this.status = SearchStatus.idle,
    this.errorMessage = '',
    this.query = '',
  });

  SearchState copyWith({
    List<Verse>? verses,
    SearchStatus? status,
    String? errorMessage,
    String? query,
  }) {
    return SearchState(
      verses: verses ?? this.verses,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    state = state.copyWith(
      status: SearchStatus.loading,
      query: query,
      errorMessage: '',
    );

    try {
      final verses = await GeminiService.search(query);
      state = state.copyWith(
        verses: verses,
        status: SearchStatus.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void reset() {
    state = const SearchState();
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
