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

  // ─────────────────────────────────────────────────────────
  // Palette — "Dawn"
  // 따뜻한 차콜 배경 + 산호빛(코랄 피치) 액센트.
  // 새벽처럼 부드럽고, 누구나 편안하게 느끼는 톤.
  // ─────────────────────────────────────────────────────────
  static const Color bgPrimary = Color(0xFF16141C);
  static const Color bgGradientTop = Color(0xFF1F1B26);
  static const Color bgCard = Color(0xFF22202B);
  static const Color bgCardLight = Color(0xFF2D2A38);

  // 산호빛 코랄 — 따뜻하고 친근한 액센트
  static const Color accent = Color(0xFFF2A88F);
  static const Color accentBright = Color(0xFFFFC4AC);
  static const Color accentDeep = Color(0xFFE38971);
  static const Color accentSoft = Color(0x33F2A88F); // ~20%
  static const Color accentGhost = Color(0x1AF2A88F); // ~10%

  // 보조 액센트 — 차분한 라벤더(보라 톤은 살짝만 살림)
  static const Color secondary = Color(0xFFB5A8E6);
  static const Color secondarySoft = Color(0x26B5A8E6);

  static const Color textPrimary = Color(0xFFF2EFEB);
  static const Color textSecondary = Color(0xFFC4BFCA);
  static const Color textDim = Color(0xFF8B8597);

  // 카드 경계는 얇은 흰색 hairline — 차가운 골드 라인보다 부드러움
  static const Color border = Color(0x14FFFFFF);
  static const Color borderSoft = Color(0x0AFFFFFF);
  static const Color divider = Color(0x1AFFFFFF);

  // 누구나 편안한 그린/레드
  static const Color success = Color(0xFF8FD9B6);
  static const Color danger = Color(0xFFE89191);

  // 어두운 배경 위에 코랄 버튼을 눌렀을 때의 글씨 색
  static const Color onAccent = Color(0xFF1F1810);

  // Mood Colors — 화면 전반에서 톤이 통일되도록 부드럽게 재조정
  static const Map<String, MoodConfig> moodConfigs = {
    'comfort': MoodConfig(
      emoji: '🫂',
      name: '위로',
      startColor: Color(0x1F7AA8FF),
      endColor: Color(0x1FB199F5),
    ),
    'courage': MoodConfig(
      emoji: '🔥',
      name: '용기',
      startColor: Color(0x1FFF9A6B),
      endColor: Color(0x1FFF7A85),
    ),
    'hope': MoodConfig(
      emoji: '🌅',
      name: '소망',
      startColor: Color(0x1FFFC57A),
      endColor: Color(0x1FFFD891),
    ),
    'gratitude': MoodConfig(
      emoji: '🙏',
      name: '감사',
      startColor: Color(0x1F8FE0A8),
      endColor: Color(0x1F86D9C2),
    ),
    'peace': MoodConfig(
      emoji: '🕊️',
      name: '평안',
      startColor: Color(0x1F8FCFE8),
      endColor: Color(0x1F9DDEDC),
    ),
    'wisdom': MoodConfig(
      emoji: '💎',
      name: '지혜',
      startColor: Color(0x1FB5A8E6),
      endColor: Color(0x1F9BB1F0),
    ),
    'love': MoodConfig(
      emoji: '❤️',
      name: '사랑',
      startColor: Color(0x1FFF9DB8),
      endColor: Color(0x1FFFAE9D),
    ),
    'faith': MoodConfig(
      emoji: '✝️',
      name: '믿음',
      startColor: Color(0x1FFFC299),
      endColor: Color(0x1FFFAE7E),
    ),
    'healing': MoodConfig(
      emoji: '💚',
      name: '치유',
      startColor: Color(0x1F8FE0CE),
      endColor: Color(0x1F9DE5B5),
    ),
    'strength': MoodConfig(
      emoji: '💪',
      name: '힘',
      startColor: Color(0x1FFF9999),
      endColor: Color(0x1FFFB088),
    ),
  };

  // Mood별 단색 — 카드 좌측 룰, 토큰 아이콘 배경에 사용
  static const Map<String, Color> moodAccent = {
    'comfort': Color(0xFF7AA8FF),
    'courage': Color(0xFFFF9A6B),
    'hope': Color(0xFFFFC57A),
    'gratitude': Color(0xFF8FD9A8),
    'peace': Color(0xFF8FCFE8),
    'wisdom': Color(0xFFB5A8E6),
    'love': Color(0xFFFF9DB8),
    'faith': Color(0xFFFFC299),
    'healing': Color(0xFF8FE0CE),
    'strength': Color(0xFFFF9999),
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
