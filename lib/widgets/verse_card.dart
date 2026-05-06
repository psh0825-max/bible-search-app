import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../models/verse.dart';
import '../providers/bookmark_provider.dart';
import '../services/tts_service.dart';
import 'glass_card.dart';

class VerseCard extends ConsumerStatefulWidget {
  final Verse verse;

  const VerseCard({super.key, required this.verse});

  @override
  ConsumerState<VerseCard> createState() => _VerseCardState();
}

class _VerseCardState extends ConsumerState<VerseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verse = widget.verse;
    final moodConfig = AppConstants.moodConfigs[verse.mood];
    final isBookmarked =
        ref.watch(bookmarkProvider.notifier).isBookmarked(verse.reference);

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                moodConfig?.startColor ?? AppConstants.accentSoft,
                moodConfig?.endColor ?? AppConstants.accentSoft,
              ],
            ),
          ),
          child: GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 감정 이모지 + 레퍼런스
                Row(
                  children: [
                    if (moodConfig != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: Text(
                          moodConfig.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            verse.formattedReference,
                            style: const TextStyle(
                              color: AppConstants.accentBright,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          if (moodConfig != null)
                            Text(
                              moodConfig.name,
                              style: const TextStyle(
                                color: AppConstants.textDim,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 구절 텍스트
                Text(
                  verse.text,
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: 16,
                    height: 1.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // 이유
                if (verse.reason.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.04),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💬 ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            verse.reason,
                            style: const TextStyle(
                              color: AppConstants.textSecondary,
                              fontSize: 13,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // 하단 버튼
                Row(
                  children: [
                    // 듣기
                    _buildActionButton(
                      icon: Icons.volume_up_outlined,
                      label: '듣기',
                      onTap: () => TtsService.speak(verse.text),
                    ),
                    const SizedBox(width: 8),
                    // 북마크
                    _buildActionButton(
                      icon: isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      label: '저장',
                      isActive: isBookmarked,
                      onTap: () {
                        if (isBookmarked) return;
                        ref.read(bookmarkProvider.notifier).addBookmark(
                              reference: verse.reference,
                              text: verse.text,
                              reason: verse.reason,
                              mood: verse.mood,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('북마크에 저장했습니다 ⭐'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // 공유
                    _buildActionButton(
                      icon: Icons.share_outlined,
                      label: '공유',
                      onTap: () {
                        Share.share(
                          '${verse.formattedReference}\n\n${verse.text}'
                          '\n\n- ${AppConstants.appName}',
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // 노트
                    _buildActionButton(
                      icon: Icons.edit_note,
                      label: '노트',
                      onTap: () => _showNoteDialog(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isActive
              ? AppConstants.accent.withOpacity(0.3)
              : Colors.white.withOpacity(0.06),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? AppConstants.accentBright
                  : AppConstants.textDim,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppConstants.accentBright
                    : AppConstants.textDim,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext context, WidgetRef ref) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '📝 노트 작성',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          style: const TextStyle(color: AppConstants.textPrimary),
          decoration: const InputDecoration(
            hintText: '이 말씀에 대한 생각을 적어보세요...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // 먼저 북마크에 추가 (없는 경우)
              ref.read(bookmarkProvider.notifier).addBookmark(
                    reference: widget.verse.reference,
                    text: widget.verse.text,
                    reason: widget.verse.reason,
                    mood: widget.verse.mood,
                  );

              // 노트 업데이트
              final bookmarks = ref.read(bookmarkProvider);
              final bookmark = bookmarks.firstWhere(
                (b) => b.reference == widget.verse.reference,
                orElse: () => bookmarks.first,
              );
              ref
                  .read(bookmarkProvider.notifier)
                  .updateNote(bookmark.id, noteController.text);

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('노트를 저장했습니다 📝'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
