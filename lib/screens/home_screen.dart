import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/bible_provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/search_provider.dart';
import '../services/speech_service.dart';
import '../widgets/verse_card.dart';
import '../widgets/mood_chip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  bool _isListening = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submit(String query) {
    if (query.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    ref.read(searchProvider.notifier).search(query.trim());
  }

  Future<void> _toggleMic() async {
    HapticFeedback.lightImpact();
    if (_isListening) {
      await SpeechService.stopListening();
      setState(() => _isListening = false);
      return;
    }

    final available = await SpeechService.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('음성 인식을 사용할 수 없어요')),
        );
      }
      return;
    }

    setState(() => _isListening = true);
    await SpeechService.startListening(
      onResult: (text, isFinal) {
        _controller.text = text;
        if (isFinal) {
          setState(() => _isListening = false);
          _submit(text);
        }
      },
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 6) return '잠 못 드는 밤이군요';
    if (h < 12) return '좋은 아침이에요';
    if (h < 18) return '잘 지내고 계신가요';
    if (h < 22) return '오늘 하루는 어떠셨어요';
    return '오늘도 수고하셨어요';
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return Container(
      decoration: kAppBackground,
      child: Stack(
        children: [
          // 따뜻한 코랄 글로우 — 새벽빛처럼 은은하게
          Positioned(
            top: -160,
            right: -90,
            child: IgnorePointer(
              child: Container(
                width: 360,
                height: 360,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x40F2A88F),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: -140,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x33B5A8E6),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: CustomScrollView(
                slivers: [
                  // 인사말 헤더
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 26, 24, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: TextStyle(
                              color:
                                  AppConstants.textSecondary.withValues(alpha: 0.95),
                              fontSize: 13.5,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '오늘은 어떤 마음이세요?',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '몇 마디만 들려주시면, 그 마음에 어울리는\n성경 말씀을 찾아 드릴게요.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 입력 — 부드러운 카드형
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 8, 20, 14),
                      child: _SearchInput(
                        controller: _controller,
                        isListening: _isListening,
                        onMicTap: _toggleMic,
                        onSubmit: _submit,
                      ),
                    ),
                  ),

                  // 감정 칩
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        children:
                            AppConstants.suggestions.map((suggestion) {
                          final emoji = _emojiFor(suggestion);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: MoodChip(
                              emoji: emoji,
                              label: _shorten(suggestion),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _controller.text = suggestion;
                                _submit(suggestion);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 22)),

                  // 로딩
                  if (searchState.status == SearchStatus.loading)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(
                            3,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _ShimmerCard(),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 에러
                  if (searchState.status == SearchStatus.error)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppConstants.danger.withValues(alpha: 0.1),
                            border: Border.all(
                              color:
                                  AppConstants.danger.withValues(alpha: 0.35),
                              width: 0.6,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppConstants.danger, size: 30),
                              const SizedBox(height: 10),
                              Text(
                                searchState.errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppConstants.textSecondary,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 결과
                  if (searchState.status == SearchStatus.success)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final verse = searchState.verses[index];
                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              index == 0 ? 4 : 0,
                              20,
                              index == searchState.verses.length - 1
                                  ? bottomPadding
                                  : 14,
                            ),
                            child: VerseCard(verse: verse),
                          );
                        },
                        childCount: searchState.verses.length,
                      ),
                    ),

                  // 초기 — 오늘의 말씀 + 따뜻한 안내
                  if (searchState.status == SearchStatus.idle)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(20, 6, 20, bottomPadding),
                        child: Column(
                          children: [
                            const _DailyVerseCard(),
                            const SizedBox(height: 34),
                            _IdleHint(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _emojiFor(String s) {
    if (s.contains('불안') || s.contains('걱정')) return '😰';
    if (s.contains('감사')) return '🙏';
    if (s.contains('외롭') || s.contains('힘들')) return '😢';
    if (s.contains('용기')) return '🔥';
    if (s.contains('사랑')) return '❤️';
    if (s.contains('시험')) return '📖';
    if (s.contains('아파')) return '💚';
    if (s.contains('시작') || s.contains('두려')) return '🌅';
    if (s.contains('화가')) return '😤';
    if (s.contains('용서')) return '🕊️';
    return '✨';
  }

  String _shorten(String s) {
    if (s.length > 9) return '${s.substring(0, 8)}…';
    return s;
  }
}

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onMicTap;
  final ValueChanged<String> onSubmit;

  const _SearchInput({
    required this.controller,
    required this.isListening,
    required this.onMicTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow(opacity: 0.32),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppConstants.bgCard.withValues(alpha: 0.86),
          border: Border.all(
            color: AppConstants.border,
            width: 0.6,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 15,
                  height: 1.3,
                ),
                decoration: InputDecoration(
                  hintText: '예. 마음이 너무 무거워요…',
                  hintStyle: TextStyle(
                    color: AppConstants.textDim.withValues(alpha: 0.95),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onSubmitted: onSubmit,
                textInputAction: TextInputAction.search,
              ),
            ),
            // 마이크
            GestureDetector(
              onTap: onMicTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening
                      ? AppConstants.accent.withValues(alpha: 0.18)
                      : AppConstants.bgCardLight.withValues(alpha: 0.6),
                  border: Border.all(
                    color: isListening
                        ? AppConstants.accent
                        : AppConstants.border,
                    width: 0.7,
                  ),
                ),
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  color: isListening
                      ? AppConstants.accentBright
                      : AppConstants.textSecondary,
                  size: 18,
                ),
              ),
            ),
            // 검색
            GestureDetector(
              onTap: () => onSubmit(controller.text),
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppConstants.accent,
                      AppConstants.accentDeep,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.accent.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppConstants.onAccent,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 오늘의 말씀 — 검색 전 빈 화면 대신 매일 다른 구절을 보여준다.
class _DailyVerseCard extends ConsumerWidget {
  const _DailyVerseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailyVerseProvider);
    final verse = dailyAsync.valueOrNull;
    if (verse == null) return const SizedBox.shrink();

    final isBookmarked =
        ref.watch(bookmarkProvider).any((b) => b.reference == verse.reference);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: softShadow(opacity: 0.3),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppConstants.bgCard.withValues(alpha: 0.85),
          border: Border.all(
            color: AppConstants.accent.withValues(alpha: 0.3),
            width: 0.7,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x26F2A88F),
              Color(0x14B5A8E6),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.accent.withValues(alpha: 0.18),
                  ),
                  child: const Center(
                    child: Text('🌅', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  '오늘의 말씀',
                  style: TextStyle(
                    color: AppConstants.accent.withValues(alpha: 0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Text(
                  verse.formattedReference,
                  style: const TextStyle(
                    color: AppConstants.textDim,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              verse.text,
              style: AppTheme.scriptureText(
                size: 16.5,
                weight: FontWeight.w400,
                color: AppConstants.textPrimary,
                height: 1.95,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DailyAction(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  label: '저장',
                  isActive: isBookmarked,
                  onTap: () {
                    if (isBookmarked) return;
                    HapticFeedback.lightImpact();
                    ref.read(bookmarkProvider.notifier).addBookmark(
                          reference: verse.reference,
                          text: verse.text,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('마음에 담아두었어요'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _DailyAction(
                  icon: Icons.ios_share,
                  label: '공유',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Share.share(
                      '${verse.formattedReference}\n\n${verse.text}'
                      '\n\n— ${AppConstants.appName}',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DailyAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? AppConstants.accentBright : AppConstants.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isActive
              ? AppConstants.accentSoft
              : AppConstants.bgCardLight.withValues(alpha: 0.55),
          border: Border.all(
            color: isActive
                ? AppConstants.accent.withValues(alpha: 0.7)
                : AppConstants.border,
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdleHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x40F2A88F),
                Color(0x33B5A8E6),
              ],
            ),
            border: Border.all(
              color: AppConstants.accent.withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
          child: const Center(
            child: Text(
              '☕',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '편하게 말 걸어주세요',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '오늘의 기쁨, 걱정, 작은 고민까지\n무엇이든 들어드릴 준비가 되어 있어요.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppConstants.bgCard.withValues(alpha: 0.65),
        border: Border.all(color: AppConstants.border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _line(width: 32, height: 32, radius: 999),
              const SizedBox(width: 12),
              _line(width: 110, height: 12),
            ],
          ),
          const SizedBox(height: 18),
          _line(width: double.infinity, height: 12),
          const SizedBox(height: 9),
          _line(width: double.infinity, height: 12),
          const SizedBox(height: 9),
          _line(width: 220, height: 12),
          const SizedBox(height: 20),
          _line(width: 160, height: 10),
        ],
      ),
    );
  }

  Widget _line({required double width, required double height, double radius = 4}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.25, end: 0.55),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: AppConstants.bgCardLight.withValues(alpha: value),
          ),
        );
      },
    );
  }
}
