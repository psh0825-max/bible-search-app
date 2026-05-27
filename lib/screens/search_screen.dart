import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/bible_provider.dart';
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
      decoration: kAppBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '성경 검색',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '단어나 문장으로 말씀을 찾아보세요.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // 검색바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarWidget(
                controller: _controller,
                hintText: '예. 사랑, 평안, 요한복음 3:16',
                onChanged: _onChanged,
                onClear: _clearSearch,
              ),
            ),

            const SizedBox(height: 14),

            if (results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Text(
                  '${results.length}개의 말씀을 찾았어요',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),

            const SizedBox(height: 8),

            Expanded(
              child: results.isEmpty
                  ? _EmptyState(
                      isInitial: _controller.text.isEmpty,
                    )
                  : ListView.separated(
                      padding:
                          EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                      itemCount: results.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppConstants.bgCard.withOpacity(0.78),
                            border: Border.all(
                              color: AppConstants.border,
                              width: 0.6,
                            ),
                            boxShadow: softShadow(opacity: 0.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['reference'] as String,
                                style: const TextStyle(
                                  color: AppConstants.accentBright,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item['text'] as String,
                                style: AppTheme.scriptureText(
                                  size: 15,
                                  weight: FontWeight.w400,
                                  color: AppConstants.textPrimary,
                                  height: 1.9,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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

class _EmptyState extends StatelessWidget {
  final bool isInitial;
  const _EmptyState({required this.isInitial});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppConstants.accent.withOpacity(0.12),
              border: Border.all(
                color: AppConstants.accent.withOpacity(0.3),
                width: 0.8,
              ),
            ),
            child: Icon(
              isInitial ? Icons.menu_book : Icons.search_off,
              color: AppConstants.accentBright,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isInitial
                ? '어떤 말씀을 찾아드릴까요?'
                : '딱 맞는 결과가 없어요',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            isInitial
                ? '키워드를 입력하면 바로 찾아드려요.'
                : '다른 단어로 다시 찾아보세요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
