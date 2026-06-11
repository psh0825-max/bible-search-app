import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../models/bible_book.dart';
import '../providers/bible_provider.dart';
import '../providers/settings_provider.dart';
import '../services/tts_service.dart';
import 'search_screen.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  BibleBook? _selectedBook;
  int? _selectedChapter;
  late PageController _pageController;
  int _testamentTab = 0; // 0: 구약, 1: 신약

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    TtsService.stop();
    super.dispose();
  }

  void _selectBook(BibleBook book) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedBook = book;
      _selectedChapter = null;
    });
  }

  void _selectChapter(int chapter) {
    HapticFeedback.selectionClick();
    setState(() => _selectedChapter = chapter);
    _pageController = PageController(initialPage: chapter - 1);
    ref
        .read(settingsProvider.notifier)
        .setLastRead(_selectedBook!.volume, chapter);
  }

  void _resumeLastRead(BibleBook book, int chapter) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedBook = book;
      _selectedChapter = chapter;
    });
    _pageController = PageController(initialPage: chapter - 1);
  }

  void _goBack() {
    TtsService.stop();
    if (_selectedChapter != null) {
      setState(() => _selectedChapter = null);
    } else if (_selectedBook != null) {
      setState(() => _selectedBook = null);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  if (_selectedBook != null)
                    GestureDetector(
                      onTap: _goBack,
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppConstants.bgCard.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppConstants.border,
                            width: 0.6,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppConstants.textSecondary,
                          size: 15,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: _selectedBook != null ? 0 : 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedBook == null) ...[
                            Text(
                              '성경 읽기',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '한 장씩 천천히, 마음 가는 대로.',
                              style:
                                  Theme.of(context).textTheme.bodyMedium,
                            ),
                          ] else
                            Text(
                              _getTitle(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedChapter != null) ...[
                    _buildTtsButton(),
                    const SizedBox(width: 8),
                    _buildFontSizeButton(),
                  ] else if (_selectedBook == null)
                    _buildKeywordSearchButton(),
                ],
              ),
            ),

            // 이어 읽기 카드
            if (_selectedBook == null) _buildResumeCard(),

            // 구약/신약 탭
            if (_selectedBook == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                child: _buildTestamentTabs(),
              ),

            // 컨텐츠
            Expanded(
              child: _selectedChapter != null
                  ? _buildVerseView(bottomPadding)
                  : _selectedBook != null
                      ? _buildChapterGrid(bottomPadding)
                      : _buildBookGrid(bottomPadding),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    if (_selectedChapter != null) {
      return '${_selectedBook!.name} $_selectedChapter장';
    }
    if (_selectedBook != null) {
      return _selectedBook!.name;
    }
    return '성경 읽기';
  }

  // === 이어 읽기 카드 ===
  Widget _buildResumeCard() {
    final settings = ref.watch(settingsProvider);
    if (!settings.hasLastRead) return const SizedBox.shrink();

    final books = ref.watch(booksProvider).valueOrNull ?? [];
    BibleBook? lastBook;
    for (final b in books) {
      if (b.volume == settings.lastReadVolume) {
        lastBook = b;
        break;
      }
    }
    if (lastBook == null) return const SizedBox.shrink();
    final chapter = settings.lastReadChapter!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: GestureDetector(
        onTap: () => _resumeLastRead(lastBook!, chapter),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: softShadow(opacity: 0.25),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppConstants.bgCard.withValues(alpha: 0.85),
              border: Border.all(
                color: AppConstants.accent.withValues(alpha: 0.35),
                width: 0.7,
              ),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0x26F2A88F),
                  Color(0x0DF2A88F),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.accent.withValues(alpha: 0.18),
                    border: Border.all(
                      color: AppConstants.accent.withValues(alpha: 0.45),
                      width: 0.7,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    color: AppConstants.accentBright,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이어 읽기',
                        style: TextStyle(
                          color: AppConstants.textDim,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${lastBook.name} $chapter장',
                        style: const TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [
                        AppConstants.accent,
                        AppConstants.accentDeep,
                      ],
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '계속',
                        style: TextStyle(
                          color: AppConstants.onAccent,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppConstants.onAccent,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === 구약/신약 탭 ===
  Widget _buildTestamentTabs() {
    final books = (ref.watch(booksProvider).valueOrNull ?? []);
    final otCount = books.where((b) => b.isOldTestament).length;
    final ntCount = books.where((b) => !b.isOldTestament).length;

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.bgCard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppConstants.border, width: 0.6),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTestamentTab(0, '구약 $otCount권'),
          _buildTestamentTab(1, '신약 $ntCount권'),
        ],
      ),
    );
  }

  Widget _buildTestamentTab(int index, String label) {
    final isSelected = _testamentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _testamentTab = index);
        },
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

  // === 3열 책 그리드 ===
  Widget _buildBookGrid(double bottomPadding) {
    final books = (ref.watch(booksProvider).valueOrNull ?? []);
    final filteredBooks = _testamentTab == 0
        ? books.where((b) => b.isOldTestament).toList()
        : books.where((b) => !b.isOldTestament).toList();

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: filteredBooks.length,
      itemBuilder: (context, index) {
        final book = filteredBooks[index];
        return GestureDetector(
          onTap: () => _selectBook(book),
          child: Container(
            decoration: BoxDecoration(
              color: AppConstants.bgCard.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppConstants.border,
                width: 0.6,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  book.name,
                  style: AppTheme.scriptureText(
                    size: 15,
                    weight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${book.chapterCount}장',
                  style: const TextStyle(
                    color: AppConstants.textDim,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // === 장 선택 그리드 ===
  Widget _buildChapterGrid(double bottomPadding) {
    final chapterCount = _selectedBook!.chapterCount;
    final settings = ref.watch(settingsProvider);
    final readChapters = settings.readChapters;

    int readCount = 0;
    for (int ch = 1; ch <= chapterCount; ch++) {
      if (readChapters.contains('${_selectedBook!.volume}:$ch')) readCount++;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                '$readCount / $chapterCount장 읽음',
                style: TextStyle(
                  color: readCount == chapterCount
                      ? AppConstants.success
                      : AppConstants.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (readCount == chapterCount)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.check_circle,
                      color: AppConstants.success, size: 14),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: chapterCount,
            itemBuilder: (context, index) {
              final chapter = index + 1;
              final isRead = readChapters
                  .contains('${_selectedBook!.volume}:$chapter');

              return GestureDetector(
                onTap: () => _selectChapter(chapter),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isRead
                        ? AppConstants.accentSoft
                        : AppConstants.bgCard.withValues(alpha: 0.65),
                    border: Border.all(
                      color: isRead
                          ? AppConstants.accent.withValues(alpha: 0.65)
                          : AppConstants.border,
                      width: 0.6,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$chapter',
                      style: TextStyle(
                        color: isRead
                            ? AppConstants.accentBright
                            : AppConstants.textPrimary,
                        fontWeight:
                            isRead ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 15,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // === 구절 보기 ===
  Widget _buildVerseView(double bottomPadding) {
    final totalChapters = _selectedBook!.chapterCount;

    return PageView.builder(
      controller: _pageController,
      itemCount: totalChapters,
      onPageChanged: (page) {
        TtsService.stop();
        setState(() => _selectedChapter = page + 1);
        ref
            .read(settingsProvider.notifier)
            .setLastRead(_selectedBook!.volume, page + 1);
      },
      itemBuilder: (context, pageIndex) {
        final chapter = pageIndex + 1;
        final key = ChapterKey(_selectedBook!.volume, chapter);
        final chapterAsync = ref.watch(chapterProvider(key));

        return chapterAsync.when(
          data: (verses) {
            final fontSize = ref.watch(settingsProvider).fontSize;
            final settings = ref.watch(settingsProvider);
            final chapterKey = '${_selectedBook!.volume}:$chapter';
            final isRead = settings.readChapters.contains(chapterKey);

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(24, 4, 24, bottomPadding),
              itemCount: verses.length + 1,
              itemBuilder: (context, index) {
                if (index == verses.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 28, bottom: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          if (isRead) {
                            ref
                                .read(settingsProvider.notifier)
                                .unmarkChapterRead(
                                    _selectedBook!.volume, chapter);
                          } else {
                            ref
                                .read(settingsProvider.notifier)
                                .markChapterRead(
                                    _selectedBook!.volume, chapter);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 13),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: isRead
                                ? LinearGradient(colors: [
                                    AppConstants.success.withValues(alpha: 0.25),
                                    AppConstants.success.withValues(alpha: 0.18),
                                  ])
                                : const LinearGradient(
                                    colors: [
                                      AppConstants.accent,
                                      AppConstants.accentDeep,
                                    ],
                                  ),
                            boxShadow: isRead
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppConstants.accent
                                          .withValues(alpha: 0.35),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isRead
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: isRead
                                    ? AppConstants.success
                                    : AppConstants.onAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isRead
                                    ? '읽음 표시 완료'
                                    : '이 장을 읽었어요',
                                style: TextStyle(
                                  color: isRead
                                      ? AppConstants.success
                                      : AppConstants.onAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 30,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: AppConstants.accent.withValues(alpha: 0.9),
                              fontSize: fontSize * 0.65,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          verses[index],
                          style: AppTheme.scriptureText(
                            size: fontSize,
                            weight: FontWeight.w400,
                            color: AppConstants.textPrimary,
                            height: 2.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppConstants.accent,
              strokeWidth: 2,
            ),
          ),
          error: (err, _) => const Center(
            child: Text(
              '말씀을 불러오지 못했어요',
              style: TextStyle(color: AppConstants.textDim),
            ),
          ),
        );
      },
    );
  }

  // TTS 버튼 — 재생 상태에 따라 아이콘이 자동으로 토글
  Widget _buildTtsButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: TtsService.speaking,
      builder: (context, speaking, _) {
        return GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            if (speaking) {
              await TtsService.stop();
              return;
            }
            final key = ChapterKey(_selectedBook!.volume, _selectedChapter!);
            final chapterAsync = ref.read(chapterProvider(key));
            final verses = chapterAsync.valueOrNull;
            if (verses == null || verses.isEmpty) return;
            final text = verses.asMap().entries.map((e) {
              return '${e.key + 1}절. ${e.value}';
            }).join('. ');
            await TtsService.speak(text);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: speaking
                  ? AppConstants.accent
                  : AppConstants.bgCard.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: speaking ? AppConstants.accent : AppConstants.border,
                width: 0.6,
              ),
            ),
            child: Icon(
              speaking ? Icons.stop : Icons.volume_up_outlined,
              color: speaking
                  ? AppConstants.onAccent
                  : AppConstants.textSecondary,
              size: 18,
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeywordSearchButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppConstants.bgCard.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppConstants.border,
            width: 0.6,
          ),
        ),
        child: const Icon(
          Icons.search,
          color: AppConstants.textSecondary,
          size: 17,
        ),
      ),
    );
  }

  Widget _buildFontSizeButton() {
    return GestureDetector(
      onTap: () => _showFontSizeSlider(),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppConstants.bgCard.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppConstants.border,
            width: 0.6,
          ),
        ),
        child: const Icon(
          Icons.text_fields,
          color: AppConstants.textSecondary,
          size: 17,
        ),
      ),
    );
  }

  void _showFontSizeSlider() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final fontSize = ref.watch(settingsProvider).fontSize;
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
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
                  const SizedBox(height: 18),
                  Text(
                    '글씨 크기',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('가',
                          style: TextStyle(
                              color: AppConstants.textDim, fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: fontSize,
                          min: 12,
                          max: 28,
                          divisions: 16,
                          label: '${fontSize.round()}',
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .setFontSize(v),
                        ),
                      ),
                      const Text('가',
                          style: TextStyle(
                              color: AppConstants.textPrimary,
                              fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '미리보기 — 사랑은 오래 참고 사랑은 온유하며',
                    style: AppTheme.scriptureText(
                      size: fontSize,
                      color: AppConstants.textPrimary,
                      height: 1.9,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
