import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/glass_card.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkProvider);
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
                  Text(
                    '⭐ 북마크',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  if (bookmarks.isNotEmpty)
                    Text(
                      '${bookmarks.length}개',
                      style: const TextStyle(
                        color: AppConstants.textDim,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

            // 리스트
            Expanded(
              child: bookmarks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: AppConstants.textDim.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '아직 북마크한 말씀이 없습니다',
                            style: TextStyle(
                              color: AppConstants.textDim.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '마음에 드는 구절에서 ⭐를 눌러보세요',
                            style: TextStyle(
                              color: AppConstants.textDim.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding:
                          EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                      itemCount: bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks[index];
                        final moodConfig =
                            AppConstants.moodConfigs[bookmark.mood];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key(bookmark.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color(0xFFEF4444).withOpacity(0.2),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppConstants.bgCard,
                                  title: const Text(
                                    '북마크 삭제',
                                    style: TextStyle(
                                        color: AppConstants.textPrimary),
                                  ),
                                  content: const Text(
                                    '이 북마크를 삭제하시겠습니까?',
                                    style: TextStyle(
                                        color: AppConstants.textSecondary),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text(
                                        '삭제',
                                        style:
                                            TextStyle(color: Color(0xFFEF4444)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) {
                              ref
                                  .read(bookmarkProvider.notifier)
                                  .removeBookmark(bookmark.id);
                            },
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 레퍼런스 + 무드
                                  Row(
                                    children: [
                                      if (moodConfig != null)
                                        Text(
                                          moodConfig.emoji,
                                          style:
                                              const TextStyle(fontSize: 18),
                                        ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          bookmark.reference,
                                          style: const TextStyle(
                                            color: AppConstants.accentBright,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      // 공유 버튼
                                      GestureDetector(
                                        onTap: () {
                                          Share.share(
                                            '${bookmark.reference}\n\n${bookmark.text}\n\n- ${AppConstants.appName}',
                                          );
                                        },
                                        child: const Icon(
                                          Icons.share_outlined,
                                          color: AppConstants.textDim,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // 구절 텍스트
                                  Text(
                                    bookmark.text,
                                    style: const TextStyle(
                                      color: AppConstants.textPrimary,
                                      fontSize: 15,
                                      height: 1.7,
                                    ),
                                  ),

                                  // 노트
                                  if (bookmark.note != null &&
                                      bookmark.note!.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        color: AppConstants.bgCardLight
                                            .withOpacity(0.5),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.edit_note,
                                            color: AppConstants.textDim,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              bookmark.note!,
                                              style: const TextStyle(
                                                color:
                                                    AppConstants.textSecondary,
                                                fontSize: 13,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // 날짜
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatDate(bookmark.createdAt),
                                    style: const TextStyle(
                                      color: AppConstants.textDim,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
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

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
