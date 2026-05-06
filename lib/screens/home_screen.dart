import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../providers/search_provider.dart';
import '../services/speech_service.dart';
import '../widgets/verse_card.dart';
import '../widgets/mood_chip.dart';
import '../widgets/glass_card.dart';

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
      duration: const Duration(milliseconds: 800),
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
    FocusScope.of(context).unfocus();
    ref.read(searchProvider.notifier).search(query.trim());
  }

  Future<void> _toggleMic() async {
    if (_isListening) {
      await SpeechService.stopListening();
      setState(() => _isListening = false);
      return;
    }

    final available = await SpeechService.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('음성 인식을 사용할 수 없습니다')),
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

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0640),
            AppConstants.bgPrimary,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            slivers: [
              // 타이틀
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ ${AppConstants.appName}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '마음을 나누면, 말씀이 찾아갑니다',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              // 입력창
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(
                              color: AppConstants.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: '지금 마음이 어떠세요?',
                              hintStyle: TextStyle(
                                color: AppConstants.textDim.withOpacity(0.7),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: _submit,
                            textInputAction: TextInputAction.search,
                          ),
                        ),
                        // 마이크 버튼
                        GestureDetector(
                          onTap: _toggleMic,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isListening
                                  ? AppConstants.accent
                                  : AppConstants.accentSoft,
                              boxShadow: _isListening
                                  ? [
                                      BoxShadow(
                                        color: AppConstants.accent
                                            .withOpacity(0.5),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening
                                  ? Colors.white
                                  : AppConstants.accentBright,
                              size: 22,
                            ),
                          ),
                        ),
                        // 검색 버튼
                        GestureDetector(
                          onTap: () => _submit(_controller.text),
                          child: Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppConstants.accent,
                            ),
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 감정 칩
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: AppConstants.suggestions.map((suggestion) {
                      final emoji = _getEmojiForSuggestion(suggestion);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: MoodChip(
                          emoji: emoji,
                          label: _shortenSuggestion(suggestion),
                          onTap: () {
                            _controller.text = suggestion;
                            _submit(suggestion);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 로딩
              if (searchState.status == SearchStatus.loading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildShimmerCard(),
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
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFEF4444), size: 40),
                            const SizedBox(height: 12),
                            Text(
                              searchState.errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // 결과 카드
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
                              : 12,
                        ),
                        child: VerseCard(verse: verse),
                      );
                    },
                    childCount: searchState.verses.length,
                  ),
                ),

              // 초기 상태 - 안내
              if (searchState.status == SearchStatus.idle)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 40, 20, bottomPadding),
                    child: Column(
                      children: [
                        const Text(
                          '🌌',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '마음의 이야기를 들려주세요',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI가 당신의 마음에 맞는\n성경 말씀을 찾아드립니다',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerLine(width: 100, height: 14),
            const SizedBox(height: 12),
            _shimmerLine(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            _shimmerLine(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            _shimmerLine(width: 200, height: 14),
            const SizedBox(height: 16),
            _shimmerLine(width: 160, height: 12),
          ],
        ),
      ),
    );
  }

  Widget _shimmerLine({required double width, required double height}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppConstants.bgCardLight.withOpacity(value),
          ),
        );
      },
    );
  }

  String _getEmojiForSuggestion(String suggestion) {
    if (suggestion.contains('불안') || suggestion.contains('걱정')) return '😰';
    if (suggestion.contains('감사')) return '🙏';
    if (suggestion.contains('외롭') || suggestion.contains('힘들')) return '😢';
    if (suggestion.contains('용기')) return '🔥';
    if (suggestion.contains('사랑')) return '❤️';
    if (suggestion.contains('시험')) return '📖';
    if (suggestion.contains('아파')) return '💚';
    if (suggestion.contains('시작') || suggestion.contains('두려')) return '🌅';
    if (suggestion.contains('화가')) return '😤';
    if (suggestion.contains('용서')) return '🕊️';
    return '✨';
  }

  String _shortenSuggestion(String suggestion) {
    if (suggestion.length > 8) return '${suggestion.substring(0, 7)}…';
    return suggestion;
  }
}
