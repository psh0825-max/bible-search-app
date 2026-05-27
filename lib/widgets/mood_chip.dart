import 'package:flutter/material.dart';
import '../config/constants.dart';

/// 감정 칩 — 부드러운 pill, 활성 시 코랄 fill. 안 누른 상태에서도 또렷.
class MoodChip extends StatefulWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodChip({
    super.key,
    required this.emoji,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<MoodChip> createState() => _MoodChipState();
}

class _MoodChipState extends State<MoodChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected || _pressed;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active
              ? AppConstants.accentSoft
              : AppConstants.bgCard.withOpacity(0.85),
          border: Border.all(
            color: active
                ? AppConstants.accent.withOpacity(0.7)
                : AppConstants.border,
            width: 0.7,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 7),
            Text(
              widget.label,
              style: TextStyle(
                color: active
                    ? AppConstants.accentBright
                    : AppConstants.textSecondary,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
