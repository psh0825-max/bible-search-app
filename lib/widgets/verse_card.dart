import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../models/verse.dart';
import '../providers/bookmark_provider.dart';
import '../services/tts_service.dart';

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
      duration: const Duration(milliseconds: 520),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
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
    final moodColor =
        AppConstants.moodAccent[verse.mood] ?? AppConstants.accent;
    final isBookmarked =
        ref.watch(bookmarkProvider.notifier).isBookmarked(verse.reference);

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: softShadow(opacity: 0.32),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: AppConstants.bgCard.withOpacity(0.85),
              border: Border.all(
                color: AppConstants.border,
                width: 0.6,
              ),
              gradient: moodConfig == null
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        moodConfig.startColor,
                        Colors.transparent,
                      ],
                    ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 — 무드 토큰(원형) + reference + 무드명
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (moodConfig != null) ...[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: moodColor.withOpacity(0.18),
                          border: Border.all(
                            color: moodColor.withOpacity(0.45),
                            width: 0.8,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            moodConfig.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
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
                              letterSpacing: -0.1,
                            ),
                          ),
                          if (moodConfig != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                moodConfig.name,
                                style: const TextStyle(
                                  color: AppConstants.textDim,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 구절 본문 — 세리프, 책 읽듯이 편안하게
                Text(
                  verse.text,
                  style: AppTheme.scriptureText(
                    size: 17.5,
                    weight: FontWeight.w400,
                    color: AppConstants.textPrimary,
                    height: 2.0,
                  ),
                ),

                // 닿는 이유 — 따뜻한 라벨
                if (verse.reason.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppConstants.bgCardLight.withOpacity(0.65),
                      border: Border.all(
                        color: AppConstants.border,
                        width: 0.6,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    AppConstants.accent.withOpacity(0.2),
                              ),
                              child: const Center(
                                child: Text(
                                  '✦',
                                  style: TextStyle(
                                    color: AppConstants.accentBright,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '이 말씀이 닿는 이유',
                              style: TextStyle(
                                color: AppConstants.accent
                                    .withOpacity(0.95),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          verse.reason,
                          style: const TextStyle(
                            color: AppConstants.textSecondary,
                            fontSize: 13.5,
                            height: 1.65,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // 액션 — 부드러운 fill pill
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.volume_up_outlined,
                      label: '듣기',
                      onTap: () => TtsService.speak(verse.text),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      label: '저장',
                      isActive: isBookmarked,
                      onTap: () {
                        if (isBookmarked) return;
                        ref
                            .read(bookmarkProvider.notifier)
                            .addBookmark(
                              reference: verse.reference,
                              text: verse.text,
                              reason: verse.reason,
                              mood: verse.mood,
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
                    _ActionButton(
                      icon: Icons.ios_share,
                      label: '공유',
                      onTap: () {
                        Share.share(
                          '${verse.formattedReference}\n\n${verse.text}'
                          '\n\n— ${AppConstants.appName}',
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
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

  void _showNoteDialog(BuildContext context, WidgetRef ref) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppConstants.border, width: 0.6),
        ),
        title: const Text(
          '노트 작성',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          style: const TextStyle(color: AppConstants.textPrimary),
          decoration: const InputDecoration(
            hintText: '이 말씀에 대한 생각을 자유롭게 적어보세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              '취소',
              style: TextStyle(color: AppConstants.textDim),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(bookmarkProvider.notifier).addBookmark(
                    reference: widget.verse.reference,
                    text: widget.verse.text,
                    reason: widget.verse.reason,
                    mood: widget.verse.mood,
                  );

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
                  content: Text('노트를 저장했어요'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text(
              '저장',
              style: TextStyle(
                color: AppConstants.accentBright,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppConstants.accentBright
        : AppConstants.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isActive
              ? AppConstants.accentSoft
              : AppConstants.bgCardLight.withOpacity(0.55),
          border: Border.all(
            color: isActive
                ? AppConstants.accent.withOpacity(0.7)
                : AppConstants.border,
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
