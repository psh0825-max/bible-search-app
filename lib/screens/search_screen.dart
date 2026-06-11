import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/bible_provider.dart';
import '../providers/bookmark_provider.dart';
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
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _showVerseSheet(context, item);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppConstants.bgCard.withValues(alpha: 0.78),
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
                                _HighlightedVerse(
                                  text: item['text'] as String,
                                  keyword: _controller.text.trim(),
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

  // 결과 카드 탭 → 전체 본문 + 저장/공유 시트
  void _showVerseSheet(BuildContext context, Map<String, dynamic> item) {
    final reference = item['reference'] as String;
    final text = item['text'] as String;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final isBookmarked =
                ref.watch(bookmarkProvider).any((b) => b.reference == reference);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppConstants.textDim.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      reference,
                      style: const TextStyle(
                        color: AppConstants.accentBright,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          text,
                          style: AppTheme.scriptureText(
                            size: 16.5,
                            color: AppConstants.textPrimary,
                            height: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _SheetButton(
                            icon: isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            label: isBookmarked ? '저장됨' : '저장',
                            isPrimary: true,
                            onTap: () {
                              if (isBookmarked) return;
                              HapticFeedback.lightImpact();
                              ref.read(bookmarkProvider.notifier).addBookmark(
                                    reference: reference,
                                    text: text,
                                  );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SheetButton(
                            icon: Icons.ios_share,
                            label: '공유',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Share.share(
                                '$reference\n\n$text\n\n— ${AppConstants.appName}',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _SheetButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [AppConstants.accent, AppConstants.accentDeep],
                )
              : null,
          color: isPrimary ? null : AppConstants.bgCardLight.withValues(alpha: 0.7),
          border: isPrimary
              ? null
              : Border.all(color: AppConstants.border, width: 0.6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary
                  ? AppConstants.onAccent
                  : AppConstants.textSecondary,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? AppConstants.onAccent
                    : AppConstants.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 본문에서 검색어를 코랄 톤으로 하이라이트.
class _HighlightedVerse extends StatelessWidget {
  final String text;
  final String keyword;

  const _HighlightedVerse({required this.text, required this.keyword});

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTheme.scriptureText(
      size: 15,
      weight: FontWeight.w400,
      color: AppConstants.textPrimary,
      height: 1.9,
    );

    if (keyword.isEmpty || !text.contains(keyword)) {
      return Text(
        text,
        style: baseStyle,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    final highlightStyle = baseStyle.copyWith(
      color: AppConstants.accentBright,
      fontWeight: FontWeight.w700,
      backgroundColor: AppConstants.accentGhost,
    );

    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final idx = text.indexOf(keyword, start);
      if (idx < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + keyword.length),
        style: highlightStyle,
      ));
      start = idx + keyword.length;
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
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
              color: AppConstants.accent.withValues(alpha: 0.12),
              border: Border.all(
                color: AppConstants.accent.withValues(alpha: 0.3),
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
