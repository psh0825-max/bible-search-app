import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/bookmark_provider.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkProvider);
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
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '담아둔 말씀',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '마음에 닿은 구절을 모아 두는 곳이에요.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (bookmarks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.accentSoft,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppConstants.accent.withValues(alpha: 0.5),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          '${bookmarks.length}개',
                          style: const TextStyle(
                            color: AppConstants.accentBright,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  AppConstants.accent.withValues(alpha: 0.12),
                              border: Border.all(
                                color:
                                    AppConstants.accent.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(
                              Icons.bookmark_border,
                              color: AppConstants.accentBright,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '아직 담아둔 말씀이 없어요',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '구절에서 "저장"을 누르면 여기에 모여요.',
                            style:
                                Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding:
                          EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                      itemCount: bookmarks.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks[index];
                        final moodConfig =
                            AppConstants.moodConfigs[bookmark.mood];
                        final moodColor = AppConstants
                                .moodAccent[bookmark.mood] ??
                            AppConstants.accent;

                        return Dismissible(
                          key: Key(bookmark.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color:
                                  AppConstants.danger.withValues(alpha: 0.18),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: AppConstants.danger,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppConstants.bgCard,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                      color: AppConstants.border,
                                      width: 0.6),
                                ),
                                title: const Text(
                                  '북마크 삭제',
                                  style: TextStyle(
                                      color: AppConstants.textPrimary),
                                ),
                                content: const Text(
                                  '이 북마크를 삭제할까요?',
                                  style: TextStyle(
                                      color:
                                          AppConstants.textSecondary),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text(
                                      '취소',
                                      style: TextStyle(
                                          color: AppConstants.textDim),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text(
                                      '삭제',
                                      style: TextStyle(
                                          color: AppConstants.danger,
                                          fontWeight:
                                              FontWeight.w600),
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
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: softShadow(opacity: 0.22),
                            ),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                  18, 16, 18, 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppConstants.bgCard
                                    .withValues(alpha: 0.82),
                                border: Border.all(
                                  color: AppConstants.border,
                                  width: 0.6,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (moodConfig != null) ...[
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: moodColor
                                                .withValues(alpha: 0.2),
                                            border: Border.all(
                                              color: moodColor
                                                  .withValues(alpha: 0.5),
                                              width: 0.6,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              moodConfig.emoji,
                                              style: const TextStyle(
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                      Expanded(
                                        child: Text(
                                          bookmark.reference,
                                          style: const TextStyle(
                                            color: AppConstants
                                                .accentBright,
                                            fontWeight:
                                                FontWeight.w700,
                                            fontSize: 13,
                                            letterSpacing: -0.1,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Share.share(
                                            '${bookmark.reference}\n\n${bookmark.text}\n\n— ${AppConstants.appName}',
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.ios_share,
                                            color: AppConstants.textDim,
                                            size: 17,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    bookmark.text,
                                    style: AppTheme.scriptureText(
                                      size: 15,
                                      weight: FontWeight.w400,
                                      color: AppConstants.textPrimary,
                                      height: 1.95,
                                    ),
                                  ),
                                  if (bookmark.note != null &&
                                      bookmark.note!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 10, 12, 10),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        color: AppConstants.bgCardLight
                                            .withValues(alpha: 0.55),
                                        border: Border.all(
                                          color: AppConstants.border,
                                          width: 0.6,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.edit_note,
                                            color:
                                                AppConstants.textDim,
                                            size: 15,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              bookmark.note!,
                                              style: const TextStyle(
                                                color: AppConstants
                                                    .textSecondary,
                                                fontSize: 13,
                                                height: 1.55,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Text(
                                    _formatDate(bookmark.createdAt),
                                    style: const TextStyle(
                                      color: AppConstants.textDim,
                                      fontSize: 11.5,
                                      letterSpacing: 0.1,
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
