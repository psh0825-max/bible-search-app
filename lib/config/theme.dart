import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

/// "Dawn" 테마 — Pretendard 계열 산세리프를 UI 전반에 쓰고,
/// 성경 본문에만 Noto Serif KR을 사용해 읽는 무게감을 더한다.
class AppTheme {
  static TextStyle _sans(TextStyle base) =>
      GoogleFonts.notoSansKr(textStyle: base);

  static TextStyle _serif(TextStyle base) =>
      GoogleFonts.notoSerifKr(textStyle: base);

  static TextStyle ui({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      _sans(TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      ));

  static TextStyle scriptureText({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
  }) =>
      _serif(TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      ));

  static ThemeData get darkTheme {
    final base = ThemeData(brightness: Brightness.dark);

    return base.copyWith(
      scaffoldBackgroundColor: AppConstants.bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.accent,
        secondary: AppConstants.secondary,
        surface: AppConstants.bgCard,
        error: AppConstants.danger,
        onPrimary: AppConstants.onAccent,
      ),
      textTheme: TextTheme(
        displayLarge: _sans(const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppConstants.textPrimary,
          height: 1.2,
          letterSpacing: -0.6,
        )),
        headlineLarge: _sans(const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: AppConstants.textPrimary,
          height: 1.22,
          letterSpacing: -0.5,
        )),
        headlineMedium: _sans(const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppConstants.textPrimary,
          height: 1.25,
          letterSpacing: -0.3,
        )),
        headlineSmall: _sans(const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
          height: 1.3,
          letterSpacing: -0.2,
        )),
        titleLarge: _sans(const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        )),
        titleMedium: _sans(const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        )),
        bodyLarge: _sans(const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppConstants.textPrimary,
          height: 1.7,
        )),
        bodyMedium: _sans(const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppConstants.textSecondary,
          height: 1.6,
        )),
        bodySmall: _sans(const TextStyle(
          fontSize: 12.5,
          color: AppConstants.textDim,
          letterSpacing: 0.1,
        )),
        labelLarge: _sans(const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        )),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: _sans(const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppConstants.textPrimary,
          letterSpacing: -0.2,
        )),
        iconTheme: const IconThemeData(color: AppConstants.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConstants.bgPrimary.withValues(alpha: 0.95),
        indicatorColor: AppConstants.accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _sans(const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppConstants.accentBright,
            ));
          }
          return _sans(const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppConstants.textDim,
          ));
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.bgCard.withValues(alpha: 0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppConstants.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppConstants.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppConstants.accent, width: 1.2),
        ),
        hintStyle: _sans(const TextStyle(color: AppConstants.textDim)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: AppConstants.accent,
        inactiveTrackColor: AppConstants.accentSoft,
        thumbColor: AppConstants.accentBright,
        overlayColor: AppConstants.accentSoft,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants.bgCardLight,
        contentTextStyle: _sans(const TextStyle(
          color: AppConstants.textPrimary,
          fontSize: 13.5,
        )),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppConstants.border, width: 0.6),
        ),
      ),
    );
  }
}

/// 화면 배경 — 잔잔한 dawn 그라데이션, 단일 톤에 가까움.
const BoxDecoration kAppBackground = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppConstants.bgGradientTop, AppConstants.bgPrimary],
  ),
);

/// 부드러운 카드 그림자 — hairline 대신 elevation으로 깊이감을 표현.
List<BoxShadow> softShadow({double opacity = 0.28}) => [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        blurRadius: 24,
        spreadRadius: -6,
        offset: const Offset(0, 12),
      ),
    ];
