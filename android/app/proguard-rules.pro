# Flutter 엔진/임베딩 — R8 축소 시 보존
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google Play Core (deferred components 미사용 시 누락 경고 무시)
-dontwarn com.google.android.play.core.**
