import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TtsService {
  // Google Cloud TTS
  static const String _apiKey = 'AIzaSyDgl1Ww5YqcFUBYzS36toESraEcxM9ipVA';
  static const String _endpoint =
      'https://texttospeech.googleapis.com/v1/text:synthesize';
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  // Fallback: native flutter_tts
  static final FlutterTts _nativeTts = FlutterTts();
  static bool _nativeInitialized = false;

  static bool get isSpeaking => _isPlaying;

  /// Clean verse text: remove [1절] markers etc.
  static String _cleanText(String text) {
    return text.replaceAll(RegExp(r'\[\d+절\]\s*'), '').trim();
  }

  /// Primary: Google Cloud TTS Chirp 3 HD
  static Future<void> speak(String text) async {
    final cleanText = _cleanText(text);
    if (cleanText.isEmpty) return;

    // Stop any current playback
    await stop();

    try {
      await _speakWithCloudTts(cleanText);
    } catch (e) {
      // Fallback to native TTS on failure
      print('Cloud TTS failed, falling back to native: $e');
      await _speakWithNativeTts(cleanText);
    }
  }

  /// Google Cloud TTS API call
  static Future<void> _speakWithCloudTts(String text) async {
    final response = await http
        .post(
          Uri.parse('$_endpoint?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'input': {'text': text},
            'voice': {
              'languageCode': 'ko-KR',
              'name': 'ko-KR-Chirp3-HD-Leda',
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

    // Decode base64 → MP3 bytes
    final Uint8List audioBytes = base64Decode(audioContent);

    // Write to temp file and play
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/tts_output.mp3');
    await tempFile.writeAsBytes(audioBytes);

    _isPlaying = true;
    _player.onPlayerComplete.listen((_) => _isPlaying = false);

    await _player.play(DeviceFileSource(tempFile.path));
  }

  /// Fallback: native flutter_tts (offline)
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

  /// Stop all playback
  static Future<void> stop() async {
    await _player.stop();
    await _nativeTts.stop();
    _isPlaying = false;
  }
}
