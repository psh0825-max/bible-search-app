import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../providers/bible_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/search_bar_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(keywordSearchProvider.notifier).search(value);
    });
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(keywordSearchProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(keywordSearchProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0640), AppConstants.bgPrimary],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Text(
                '🔍 성경 검색',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            // 검색바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarWidget(
                controller: _controller,
                hintText: '성경 구절 키워드를 입력하세요',
                onChanged: _onChanged,
                onClear: _clearSearch,
              ),
            ),

            const SizedBox(height: 12),

            // 결과 수
            if (results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '${results.length}개 구절을 찾았습니다',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),

            const SizedBox(height: 8),

            // 결과 리스트
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: AppConstants.textDim.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _controller.text.isEmpty
                                ? '키워드로 성경 구절을 검색해보세요'
                                : '검색 결과가 없습니다',
                            style: TextStyle(
                              color: AppConstants.textDim.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding:
                          EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['reference'] as String,
                                  style: const TextStyle(
                                    color: AppConstants.accentBright,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['text'] as String,
                                  style: const TextStyle(
                                    color: AppConstants.textPrimary,
                                    fontSize: 15,
                                    height: 1.7,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
