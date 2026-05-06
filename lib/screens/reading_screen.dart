import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../models/bible_book.dart';
import '../providers/bible_provider.dart';
import '../providers/settings_provider.dart';
import '../services/tts_service.dart';
import '../widgets/glass_card.dart';

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
    setState(() {
      _selectedBook = book;
      _selectedChapter = null;
    });
  }

  void _selectChapter(int chapter) {
    setState(() => _selectedChapter = chapter);
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
              child: Row(
                children: [
                  if (_selectedBook != null)
                    GestureDetector(
                      onTap: _goBack,
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConstants.accentSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppConstants.accentBright,
                          size: 18,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      _getTitle(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  // TTS & 글씨 크기
                  if (_selectedChapter != null) ...[
                    _buildTtsButton(),
                    const SizedBox(width: 8),
                    _buildFontSizeButton(),
                  ],
                ],
              ),
            ),

            // 구약/신약 탭 (책 목록일 때만)
            if (_selectedBook == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
    return '📖 성경 읽기';
  }

  // === 구약/신약 탭 ===
  Widget _buildTestamentTabs() {
    final books = (ref.watch(booksProvider).value ?? []);
    final otCount = books.where((b) => b.isOldTestament).length;
    final ntCount = books.where((b) => !b.isOldTestament).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
        onTap: () => setState(() => _testamentTab = index),
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

  // === 3열 책 그리드 ===
  Widget _buildBookGrid(double bottomPadding) {
    final books = (ref.watch(booksProvider).value ?? []);
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
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  book.name,
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${book.chapterCount}장',
                  style: TextStyle(
                    color: AppConstants.textDim,
                    fontSize: 12,
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
        // 이 책의 진도
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                '$readCount/$chapterCount장 읽음',
                style: TextStyle(
                  color: readCount == chapterCount
                      ? Colors.greenAccent
                      : AppConstants.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (readCount == chapterCount)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.check_circle,
                      color: Colors.greenAccent, size: 14),
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
                        ? AppConstants.accent.withOpacity(0.3)
                        : AppConstants.bgCard.withOpacity(0.5),
                    border: Border.all(
                      color: isRead
                          ? Colors.greenAccent.withOpacity(0.5)
                          : AppConstants.border,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$chapter',
                        style: TextStyle(
                          color: isRead
                              ? AppConstants.accentBright
                              : AppConstants.textPrimary,
                          fontWeight:
                              isRead ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      if (isRead)
                        const Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                            size: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // === 구절 보기 (스와이프) ===
  Widget _buildVerseView(double bottomPadding) {
    final totalChapters = _selectedBook!.chapterCount;

    return PageView.builder(
      controller: _pageController,
      itemCount: totalChapters,
      onPageChanged: (page) {
        TtsService.stop();
        setState(() => _selectedChapter = page + 1);
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
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
              itemCount: verses.length + 1,
              itemBuilder: (context, index) {
                if (index == verses.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isRead
                                ? Colors.greenAccent.withOpacity(0.15)
                                : AppConstants.accent.withOpacity(0.15),
                            border: Border.all(
                              color: isRead
                                  ? Colors.greenAccent.withOpacity(0.4)
                                  : AppConstants.accent.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isRead
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: isRead
                                    ? Colors.greenAccent
                                    : AppConstants.accentBright,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isRead
                                    ? '이 장을 읽었습니다 ✅'
                                    : '이 장을 읽음으로 표시',
                                style: TextStyle(
                                  color: isRead
                                      ? Colors.greenAccent
                                      : AppConstants.accentBright,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
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
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: AppConstants.accentBright,
                            fontSize: fontSize * 0.75,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          verses[index],
                          style: TextStyle(
                            color: AppConstants.textPrimary,
                            fontSize: fontSize,
                            height: 1.8,
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
            ),
          ),
          error: (err, _) => Center(
            child: Text(
              '구절을 불러올 수 없습니다',
              style: TextStyle(color: AppConstants.textDim),
            ),
          ),
        );
      },
    );
  }

  // TTS 버튼
  Widget _buildTtsButton() {
    return GestureDetector(
      onTap: () async {
        if (TtsService.isSpeaking) {
          await TtsService.stop();
          setState(() {});
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
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: TtsService.isSpeaking
              ? AppConstants.accent
              : AppConstants.accentSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          TtsService.isSpeaking ? Icons.stop : Icons.volume_up,
          color: TtsService.isSpeaking
              ? Colors.white
              : AppConstants.accentBright,
          size: 20,
        ),
      ),
    );
  }

  // 글씨 크기 버튼
  Widget _buildFontSizeButton() {
    return GestureDetector(
      onTap: () => _showFontSizeSlider(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppConstants.accentSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.text_fields,
          color: AppConstants.accentBright,
          size: 20,
        ),
      ),
    );
  }

  void _showFontSizeSlider() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final fontSize = ref.watch(settingsProvider).fontSize;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '글씨 크기',
                    style: TextStyle(
                      color: AppConstants.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          activeColor: AppConstants.accent,
                          inactiveColor: AppConstants.accentSoft,
                          label: '${fontSize.round()}',
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .setFontSize(v),
                        ),
                      ),
                      const Text('가',
                          style: TextStyle(
                              color: AppConstants.textPrimary, fontSize: 24)),
                    ],
                  ),
                  Text(
                    '미리보기 텍스트입니다',
                    style: TextStyle(
                      color: AppConstants.textPrimary,
                      fontSize: fontSize,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
