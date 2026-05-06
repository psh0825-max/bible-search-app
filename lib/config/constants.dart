import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = '말씀찾기';
  static const String companyName = 'LightOn Plus Lab';
  static const String copyright = '© 2026 LightOn Plus Lab';

  // Gemini API
  static const String geminiApiKey = 'AIzaSyDgl1Ww5YqcFUBYzS36toESraEcxM9ipVA';
  static const String geminiModel = 'gemini-2.5-flash';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // Colors - Dark Space Theme
  static const Color bgPrimary = Color(0xFF0F0524);
  static const Color bgCard = Color(0xFF1A0A3E);
  static const Color bgCardLight = Color(0xFF251250);
  static const Color accent = Color(0xFF7C3AED);
  static const Color accentBright = Color(0xFFA78BFA);
  static const Color accentSoft = Color(0x337C3AED);
  static const Color textPrimary = Color(0xFFEDE9FE);
  static const Color textSecondary = Color(0xFFA78BFA);
  static const Color textDim = Color(0xFF6D5A9E);
  static const Color border = Color(0x337C3AED);

  // Mood Colors
  static const Map<String, MoodConfig> moodConfigs = {
    'comfort': MoodConfig(
      emoji: '🫂',
      name: '위로',
      startColor: Color(0x333B82F6),
      endColor: Color(0x338B5CF6),
    ),
    'courage': MoodConfig(
      emoji: '🔥',
      name: '용기',
      startColor: Color(0x33F97316),
      endColor: Color(0x33EF4444),
    ),
    'hope': MoodConfig(
      emoji: '🌅',
      name: '소망',
      startColor: Color(0x33F59E0B),
      endColor: Color(0x33EAB308),
    ),
    'gratitude': MoodConfig(
      emoji: '🙏',
      name: '감사',
      startColor: Color(0x3322C55E),
      endColor: Color(0x3310B981),
    ),
    'peace': MoodConfig(
      emoji: '🕊️',
      name: '평안',
      startColor: Color(0x330EA5E9),
      endColor: Color(0x3306B6D4),
    ),
    'wisdom': MoodConfig(
      emoji: '💎',
      name: '지혜',
      startColor: Color(0x338B5CF6),
      endColor: Color(0x336366F1),
    ),
    'love': MoodConfig(
      emoji: '❤️',
      name: '사랑',
      startColor: Color(0x33EC4899),
      endColor: Color(0x33F43F5E),
    ),
    'faith': MoodConfig(
      emoji: '✝️',
      name: '믿음',
      startColor: Color(0x33F59E0B),
      endColor: Color(0x33F97316),
    ),
    'healing': MoodConfig(
      emoji: '💚',
      name: '치유',
      startColor: Color(0x3314B8A6),
      endColor: Color(0x3322C55E),
    ),
    'strength': MoodConfig(
      emoji: '💪',
      name: '힘',
      startColor: Color(0x33EF4444),
      endColor: Color(0x33F97316),
    ),
  };

  static const List<String> suggestions = [
    '마음이 불안하고 걱정이 많아요',
    '감사한 일이 있어요',
    '외롭고 힘들어요',
    '용기가 필요해요',
    '사랑에 대해 알고 싶어요',
    '시험을 앞두고 있어요',
    '가족이 아파요',
    '새로운 시작이 두려워요',
    '화가 나요',
    '용서하고 싶어요',
  ];
}

class MoodConfig {
  final String emoji;
  final String name;
  final Color startColor;
  final Color endColor;

  const MoodConfig({
    required this.emoji,
    required this.name,
    required this.startColor,
    required this.endColor,
  });

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [startColor, endColor],
      );
}
