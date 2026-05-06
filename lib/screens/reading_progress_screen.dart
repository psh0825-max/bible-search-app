import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../models/bible_book.dart';
import '../providers/bible_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass_card.dart';

class ReadingProgressScreen extends ConsumerStatefulWidget {
  const ReadingProgressScreen({super.key});

  @override
  ConsumerState<ReadingProgressScreen> createState() =>
      _ReadingProgressScreenState();
}

class _ReadingProgressScreenState extends ConsumerState<ReadingProgressScreen> {
  int _topTabIndex = 0; // 0: 진도표, 1: 읽기 플랜
  int _filterIndex = 0; // 0: 전체, 1: 구약, 2: 신약
  int? _expandedBookIndex; // 아코디언 펼쳐진 책 인덱스

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;
    final books = (ref.watch(booksProvider).value ?? []);
    final settings = ref.watch(settingsProvider);
    final readChapters = settings.readChapters;

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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
              child: Text(
                '📊 읽기 진도',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                '성경 읽기 진행상황을 확인하세요',
                style: TextStyle(
                  color: AppConstants.textDim,
                  fontSize: 14,
                ),
              ),
            ),

            // 상단 탭: 진도표 / 읽기 플랜
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTopTabs(),
            ),
            const SizedBox(height: 16),

            // 컨텐츠
            Expanded(
              child: _topTabIndex == 0
                  ? _buildProgressTab(books, readChapters, bottomPadding)
                  : _buildPlanTab(bottomPadding),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTopTab(0, '📊 진도표'),
          _buildTopTab(1, '📅 읽기 플랜'),
        ],
      ),
    );
  }

  Widget _buildTopTab(int index, String label) {
    final isSelected = _topTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _topTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF7c3aed), Color(0xFF6d28d9)],
                  )
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppConstants.textDim,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // === 진도표 탭 ===
  Widget _buildProgressTab(
      List<BibleBook> books, Set<String> readChapters, double bottomPadding) {
    // 필터링된 책 목록
    List<BibleBook> filteredBooks;
    if (_filterIndex == 1) {
      filteredBooks = books.where((b) => b.isOldTestament).toList();
    } else if (_filterIndex == 2) {
      filteredBooks = books.where((b) => !b.isOldTestament).toList();
    } else {
      filteredBooks = books;
    }

    // 통계 계산
    final totalRead = readChapters.length;
    int otRead = 0;
    int ntRead = 0;
    for (final key in readChapters) {
      final parts = key.split(':');
      final vol = int.tryParse(parts[0]) ?? 0;
      if (vol <= 39) {
        otRead++;
      } else {
        ntRead++;
      }
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
      children: [
        // 전체 진행률 카드
        _buildOverallProgressCard(totalRead, otRead, ntRead),
        const SizedBox(height: 16),

        // 필터 탭
        _buildFilterTabs(),
        const SizedBox(height: 16),

        // 책 목록 (아코디언)
        ...List.generate(filteredBooks.length, (index) {
          return _buildBookAccordion(
              filteredBooks[index], readChapters, index);
        }),
      ],
    );
  }

  Widget _buildOverallProgressCard(int totalRead, int otRead, int ntRead) {
    final totalProgress = totalRead / 1189;
    final otProgress = otRead / 929;
    final ntProgress = ntRead / 260;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 전체 진행률',
            style: TextStyle(
              color: AppConstants.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '전체 성경',
                  style: TextStyle(
                      color: AppConstants.textSecondary, fontSize: 13),
                ),
              ),
              Text(
                '$totalRead/1189 (${(totalProgress * 100).toStringAsFixed(0)}%)',
                style: TextStyle(
                    color: AppConstants.textPrimary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: totalProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.accent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '구약',
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$otRead/929 (${(otProgress * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.1),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '신약',
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$ntRead/260 (${(ntProgress * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildFilterChip(0, '전체'),
        const SizedBox(width: 8),
        _buildFilterChip(1, '구약'),
        const SizedBox(width: 8),
        _buildFilterChip(2, '신약'),
      ],
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        _filterIndex = index;
        _expandedBookIndex = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF7c3aed), Color(0xFF6d28d9)],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppConstants.textDim,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildBookAccordion(
      BibleBook book, Set<String> readChapters, int index) {
    int readCount = 0;
    for (int ch = 1; ch <= book.chapterCount; ch++) {
      if (readChapters.contains('${book.volume}:$ch')) readCount++;
    }
    final progress = readCount / book.chapterCount;
    final isExpanded = _expandedBookIndex == index;

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _expandedBookIndex = isExpanded ? null : index;
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.name,
                        style: const TextStyle(
                          color: AppConstants.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '$readCount/${book.chapterCount} (${(progress * 100).toStringAsFixed(0)}%)',
                      style: TextStyle(
                        color: AppConstants.textDim,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppConstants.textDim,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppConstants.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 펼쳐진 장 그리드
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: _buildChapterGrid(book, readChapters),
          ),
      ],
    );
  }

  Widget _buildChapterGrid(BibleBook book, Set<String> readChapters) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: book.chapterCount,
      itemBuilder: (context, index) {
        final chapter = index + 1;
        final isRead =
            readChapters.contains('${book.volume}:$chapter');

        return GestureDetector(
          onTap: () {
            final notifier = ref.read(settingsProvider.notifier);
            if (isRead) {
              notifier.unmarkChapterRead(book.volume, chapter);
            } else {
              notifier.markChapterRead(book.volume, chapter);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: isRead
                  ? AppConstants.accent.withOpacity(0.4)
                  : Colors.white.withOpacity(0.05),
              border: Border.all(
                color: isRead
                    ? AppConstants.accent.withOpacity(0.6)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: isRead
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : Text(
                      '$chapter',
                      style: TextStyle(
                        color: AppConstants.textDim,
                        fontSize: 11,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // === 읽기 플랜 탭 (placeholder) ===
  Widget _buildPlanTab(double bottomPadding) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month,
                color: AppConstants.textDim, size: 48),
            const SizedBox(height: 16),
            Text(
              '읽기 플랜 준비 중...',
              style: TextStyle(
                color: AppConstants.textDim,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '곧 다양한 성경 읽기 플랜을 제공합니다',
              style: TextStyle(
                color: AppConstants.textDim.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
