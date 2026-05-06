import 'package:flutter/material.dart';
import '../config/constants.dart';

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

class _MoodChipState extends State<MoodChip>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: widget.isSelected || _pressed
              ? AppConstants.accent.withOpacity(0.3)
              : AppConstants.bgCard.withOpacity(0.6),
          border: Border.all(
            color: widget.isSelected || _pressed
                ? AppConstants.accent.withOpacity(0.6)
                : AppConstants.border,
          ),
          boxShadow: widget.isSelected || _pressed
              ? [
                  BoxShadow(
                    color: AppConstants.accent.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.isSelected
                    ? AppConstants.accentBright
                    : AppConstants.textSecondary,
                fontSize: 13,
                fontWeight:
                    widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
