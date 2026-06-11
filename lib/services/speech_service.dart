import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  static final SpeechToText _speech = SpeechToText();
  static bool _initialized = false;
  static bool _available = false;

  static bool get isAvailable => _available;

  /// 마이크 권한을 런타임에 명시적으로 요청한 뒤 STT 초기화.
  /// speech_to_text 7.x 는 RECORD_AUDIO를 자동 요청하지 않으므로
  /// permission_handler 로 사용자 동의 다이얼로그를 띄워야 한다.
  static Future<bool> initialize() async {
    if (_initialized) return _available;

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _initialized = true;
      _available = false;
      return false;
    }

    _available = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    _initialized = true;
    return _available;
  }

  static Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function()? onDone,
  }) async {
    if (!_available) {
      final ok = await initialize();
      if (!ok) return;
    }

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: SpeechListenOptions(
        localeId: 'ko_KR',
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        partialResults: true,
        autoPunctuation: false,
      ),
    );
  }

  static Future<void> stopListening() async {
    await _speech.stop();
  }

  static bool get isListening => _speech.isListening;
}
