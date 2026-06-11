/// 빌드 시점에 주입되는 API 키.
///
/// 키를 소스에 커밋하지 않기 위해 --dart-define으로 전달한다:
///
/// ```sh
/// flutter build appbundle \
///   --dart-define=GEMINI_API_KEY=... \
///   --dart-define=CLOUD_TTS_API_KEY=...
/// ```
///
/// 키가 없으면 AI 검색은 안내 메시지를 띄우고,
/// 낭독은 기기 내장 TTS로 동작한다 (성경 읽기·키워드 검색은 영향 없음).
class ApiKeys {
  ApiKeys._();

  static const String gemini = String.fromEnvironment('GEMINI_API_KEY');

  static const String cloudTts = String.fromEnvironment(
    'CLOUD_TTS_API_KEY',
    // 별도 키가 없으면 Gemini 키와 같은 GCP 프로젝트 키를 재사용.
    defaultValue: String.fromEnvironment('GEMINI_API_KEY'),
  );

  static bool get hasGemini => gemini.isNotEmpty;
  static bool get hasCloudTts => cloudTts.isNotEmpty;
}
