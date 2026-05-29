import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Bible verse 낭독 서비스.
///
/// 1차: Google Cloud TTS — Wavenet 보이스 (Chirp 3 HD 대비 ~53% 저렴, 체감 음질 차이 미미).
/// 2차: 기기 내장 flutter_tts (오프라인 / 네트워크 실패 fallback).
///
/// 같은 텍스트는 디스크에 mp3로 캐시 → 두 번째 재생부터 API 비용 0.
class TtsService {
  static const String _apiKey = 'AIzaSyDgl1Ww5YqcFUBYzS36toESraEcxM9ipVA';
  static const String _endpoint =
      'https://texttospeech.googleapis.com/v1/text:synthesize';

  // Wavenet 한국어 보이스 (여성, 차분한 톤 — 성경 낭독에 어울림).
  static const String _voiceName = 'ko-KR-Wavenet-A';

  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static final FlutterTts _nativeTts = FlutterTts();
  static bool _nativeInitialized = false;

  static Directory? _cacheDir;

  static bool get isSpeaking => _isPlaying;

  // 절 앞의 [1절] 같은 마커 제거.
  static String _cleanText(String text) {
    return text.replaceAll(RegExp(r'\[\d+절\]\s*'), '').trim();
  }

  static String _cacheKey(String text) {
    // hashCode는 32-bit but Bible 텍스트 분포에선 충돌 무시 가능.
    final h = text.hashCode.toUnsigned(32).toRadixString(16);
    return '${_voiceName}_$h';
  }

  static Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final tmp = await getTemporaryDirectory();
    final dir = Directory('${tmp.path}/tts_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    _cacheDir = dir;
    return dir;
  }

  static Future<void> speak(String text) async {
    final cleanText = _cleanText(text);
    if (cleanText.isEmpty) return;

    await stop();

    try {
      await _speakWithCloudTts(cleanText);
    } catch (e) {
      // 네트워크/API 실패 → 기기 내장 TTS로 fallback.
      // ignore: avoid_print
      print('Cloud TTS failed, falling back to native: $e');
      await _speakWithNativeTts(cleanText);
    }
  }

  static Future<void> _speakWithCloudTts(String text) async {
    final cacheDir = await _getCacheDir();
    final cachedFile = File('${cacheDir.path}/${_cacheKey(text)}.mp3');

    if (await cachedFile.exists()) {
      await _playFile(cachedFile);
      return;
    }

    final response = await http
        .post(
          Uri.parse('$_endpoint?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'input': {'text': text},
            'voice': {
              'languageCode': 'ko-KR',
              'name': _voiceName,
            },
            'audioConfig': {
              'audioEncoding': 'MP3',
              'speakingRate': 0.95,
            },
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Cloud TTS error: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final audioContent = data['audioContent'] as String?;
    if (audioContent == null || audioContent.isEmpty) {
      throw Exception('Empty audio response');
    }

    final Uint8List audioBytes = base64Decode(audioContent);
    await cachedFile.writeAsBytes(audioBytes);
    await _playFile(cachedFile);
  }

  static Future<void> _playFile(File file) async {
    _isPlaying = true;
    _player.onPlayerComplete.listen((_) => _isPlaying = false);
    await _player.play(DeviceFileSource(file.path));
  }

  static Future<void> _speakWithNativeTts(String text) async {
    if (!_nativeInitialized) {
      await _nativeTts.setLanguage('ko-KR');
      await _nativeTts.setSpeechRate(0.5);
      await _nativeTts.setVolume(1.0);
      await _nativeTts.setPitch(1.0);
      _nativeTts.setStartHandler(() => _isPlaying = true);
      _nativeTts.setCompletionHandler(() => _isPlaying = false);
      _nativeTts.setCancelHandler(() => _isPlaying = false);
      _nativeTts.setErrorHandler((msg) => _isPlaying = false);
      _nativeInitialized = true;
    }
    _isPlaying = true;
    await _nativeTts.speak(text);
  }

  static Future<void> stop() async {
    await _player.stop();
    await _nativeTts.stop();
    _isPlaying = false;
  }
}
