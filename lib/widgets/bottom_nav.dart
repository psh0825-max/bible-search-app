import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/constants.dart';

/// 부드러운 하단 탭 — 활성 시 코랄 톤 pill이 아이콘 뒤에 떠오름.
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(
        icon: Icons.search_outlined, activeIcon: Icons.search, label: '찾기'),
    _NavItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        label: '성경'),
    _NavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: '진도'),
    _NavItem(
        icon: Icons.bookmark_border,
        activeIcon: Icons.bookmark,
        label: '저장'),
    _NavItem(
        icon: Icons.tune,
        activeIcon: Icons.tune,
        label: '설정'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: AppConstants.bgPrimary.withValues(alpha: 0.88),
            border: const Border(
              top: BorderSide(
                color: AppConstants.border,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final isSelected = index == currentIndex;

                  return GestureDetector(
                    onTap: () {
                      if (index != currentIndex) {
                        HapticFeedback.selectionClick();
                      }
                      onTap(index);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 64,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: isSelected
                                  ? AppConstants.accentSoft
                                  : Colors.transparent,
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? AppConstants.accentBright
                                  : AppConstants.textDim,
                              size: 21,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppConstants.accentBright
                                  : AppConstants.textDim,
                              fontSize: 10.5,
                              letterSpacing: -0.1,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
