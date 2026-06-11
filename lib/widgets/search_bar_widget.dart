import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/constants.dart';

/// 단일 라인 검색바 — 부드러운 pill, 가벼운 hairline.
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onMicTap;
  final bool isListening;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.hintText = '검색...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onMicTap,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppConstants.bgCard.withValues(alpha: 0.78),
            border: Border.all(
              color: AppConstants.border,
              width: 0.6,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              const Icon(
                Icons.search,
                color: AppConstants.textDim,
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: AppConstants.textDim.withValues(alpha: 0.9),
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textInputAction: TextInputAction.search,
                ),
              ),
              if (controller.text.isNotEmpty && onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.close,
                      color: AppConstants.textDim,
                      size: 18,
                    ),
                  ),
                ),
              if (onMicTap != null)
                GestureDetector(
                  onTap: onMicTap,
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening
                          ? AppConstants.accent
                          : Colors.transparent,
                    ),
                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: isListening
                          ? AppConstants.onAccent
                          : AppConstants.textDim,
                      size: 18,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
