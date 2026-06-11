import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../models/bible_book.dart';
import '../providers/bible_provider.dart';
import '../providers/settings_provider.dart';

class ReadingProgressScreen extends ConsumerStatefulWidget {
  const ReadingProgressScreen({super.key});

  @override
  ConsumerState<ReadingProgressScreen> createState() =>
      _ReadingProgressScreenState();
}

class _ReadingProgressScreenState extends ConsumerState<ReadingProgressScreen> {
  int _topTabIndex = 0;
  int _filterIndex = 0;
  int? _expandedBookIndex;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;
    final books = (ref.watch(booksProvider).valueOrNull ?? []);
    final settings = ref.watch(settingsProvider);
    final readChapters = settings.readChapters;

    return Container(
      decoration: kAppBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 4),
              child: Text(
                '읽기 진도',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
              child: Text(
                '얼만큼 읽어왔는지 함께 보실래요?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            // 상단 탭
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTopTabs(),
            ),
            const SizedBox(height: 18),

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
        color: AppConstants.bgCard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppConstants.border, width: 0.6),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTopTab(0, '진도표'),
          _buildTopTab(1, '읽기 플랜'),
        ],
      ),
    );
  }

  Widget _buildTopTab(int index, String label) {
    final isSelected = _topTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _topTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      AppConstants.accent,
                      AppConstants.accentDeep,
                    ],
                  )
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? AppConstants.onAccent
                  : AppConstants.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13.5,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }

  // === 진도표 탭 ===
  Widget _buildProgressTab(
      List<BibleBook> books, Set<String> readChapters, double bottomPadding) {
    List<BibleBook> filteredBooks;
    if (_filterIndex == 1) {
      filteredBooks = books.where((b) => b.isOldTestament).toList();
    } else if (_filterIndex == 2) {
      filteredBooks = books.where((b) => !b.isOldTestament).toList();
    } else {
      filteredBooks = books;
    }

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
        _buildOverallProgressCard(totalRead, otRead, ntRead),
        const SizedBox(height: 18),
        _buildFilterTabs(),
        const SizedBox(height: 14),
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

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow(opacity: 0.25),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppConstants.bgCard.withValues(alpha: 0.82),
          border: Border.all(color: AppConstants.border, width: 0.6),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x1FF2A88F),
              Color(0x14B5A8E6),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '전체 진행률',
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (totalProgress * 100).toStringAsFixed(0),
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -0.6,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 5, left: 2),
                  child: Text(
                    '%',
                    style: TextStyle(
                      color: AppConstants.accentBright,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$totalRead / 1,189장',
                  style: const TextStyle(
                    color: AppConstants.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: totalProgress,
                minHeight: 8,
                backgroundColor: AppConstants.bgCardLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppConstants.accent),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppConstants.divider, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _miniStat('구약', otRead, 929, otProgress)),
                Container(
                  width: 1,
                  height: 40,
                  color: AppConstants.divider,
                ),
                Expanded(child: _miniStat('신약', ntRead, 260, ntProgress)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, int read, int total, double progress) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppConstants.textDim,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$read / $total',
          style: const TextStyle(
            color: AppConstants.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            color: AppConstants.accentBright,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppConstants.accent,
                    AppConstants.accentDeep,
                  ],
                )
              : null,
          color: isSelected ? null : AppConstants.bgCard.withValues(alpha: 0.65),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppConstants.border,
            width: 0.6,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppConstants.onAccent
                : AppConstants.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12.5,
            letterSpacing: -0.1,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.bgCard.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppConstants.border,
                width: 0.6,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.name,
                        style: AppTheme.scriptureText(
                          size: 14.5,
                          weight: FontWeight.w600,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '$readCount/${book.chapterCount}  ·  ${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppConstants.textDim,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 180),
                      turns: isExpanded ? 0.5 : 0,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppConstants.textDim,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppConstants.bgCardLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppConstants.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.bgPrimary.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppConstants.border, width: 0.6),
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
        final isRead = readChapters.contains('${book.volume}:$chapter');

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
              borderRadius: BorderRadius.circular(7),
              color: isRead
                  ? AppConstants.accentSoft
                  : AppConstants.bgCard.withValues(alpha: 0.4),
              border: Border.all(
                color: isRead
                    ? AppConstants.accent.withValues(alpha: 0.7)
                    : AppConstants.border,
                width: 0.6,
              ),
            ),
            child: Center(
              child: isRead
                  ? const Icon(Icons.check,
                      color: AppConstants.accentBright, size: 12)
                  : Text(
                      '$chapter',
                      style: const TextStyle(
                        color: AppConstants.textDim,
                        fontSize: 10.5,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanTab(double bottomPadding) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              child: const Icon(
                Icons.calendar_month,
                color: AppConstants.accentBright,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '읽기 플랜은 곧 만나요',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              '하루치 분량을 정해드릴 수 있도록 준비 중이에요.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
