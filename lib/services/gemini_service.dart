import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/verse.dart';
import 'bible_db_service.dart';

class GeminiService {
  static const String _systemPrompt = '''당신은 성경 전문가입니다. 사용자가 자신의 감정, 상황, 고민을 설명하면 가장 적합한 성경 구절 3~5개의 **위치**를 알려주세요.

반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트 없이 JSON만 출력하세요.

[
  {
    "book": "책이름 (예: 시편, 잠언, 요한복음, 로마서 등 - 정식 한글 이름)",
    "chapter": 장번호,
    "startVerse": 시작절,
    "endVerse": 끝절,
    "reason": "왜 이 구절이 지금 상황에 맞는지 따뜻한 한 문장으로",
    "mood": "comfort | courage | hope | gratitude | peace | wisdom | love | faith"
  }
]

규칙:
- 반드시 실제 존재하는 성경 구절 위치만 사용
- 책이름은 한글 정식 이름 사용
- endVerse는 startVerse와 같거나 최대 3절까지
- reason은 따뜻하고 위로가 되는 말투로
- 다양한 성경 책에서 골라주세요''';

  static Future<List<Verse>> search(String query) async {
    // Try direct lookup first
    final directResults = _tryDirectLookup(query);
    if (directResults != null) return directResults;

    final url = Uri.parse(
        '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent?key=${AppConstants.geminiApiKey}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': '$_systemPrompt\n\n사용자의 마음: "$query"'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 2000,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI 서비스 오류가 발생했습니다');
    }

    final data = json.decode(response.body);
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

    final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(text);
    if (jsonMatch == null) {
      throw Exception('구절을 찾지 못했습니다');
    }

    final List<dynamic> locations = json.decode(jsonMatch.group(0)!);
    final List<Verse> verses = [];

    for (final loc in locations) {
      final book = loc['book'] as String;
      final chapter = loc['chapter'] as int;
      final startV = loc['startVerse'] as int;
      final endV = loc['endVerse'] as int;

      String? verseText;
      if (startV == endV) {
        verseText = await BibleDbService.getVerse(book, chapter, startV);
      } else {
        verseText =
            await BibleDbService.getVerseRange(book, chapter, startV, endV);
      }

      if (verseText != null) {
        final reference = startV == endV
            ? '$book $chapter:$startV'
            : '$book $chapter:$startV-$endV';
        verses.add(Verse(
          reference: reference,
          text: verseText,
          reason: loc['reason'] ?? '',
          mood: loc['mood'] ?? 'faith',
        ));
      }
    }

    if (verses.isEmpty) {
      throw Exception('구절을 찾지 못했습니다. 다시 시도해주세요.');
    }

    return verses;
  }

  static Future<List<Verse>>? _tryDirectLookup(String query) {
    // Patterns: "요한복음 3장 16절", "시편 23:1-6", "창 1:1", etc.
    String q = query.trim();

    // If starts with number + 편, assume 시편
    if (RegExp(r'^\d+\s*편').hasMatch(q)) {
      q = '시편 $q';
    }

    final patterns = [
      // "요한복음 3장 1절에서 7절"
      RegExp(r'([가-힣]+(?:\s?[가-힣]*)?)\s*(\d+)\s*(?:장|편)\s*(\d+)\s*절?\s*(?:에서|부터|~|-|–)\s*(\d+)\s*절?'),
      // "요한복음 3장 16-18절"
      RegExp(r'([가-힣]+(?:\s?[가-힣]*)?)\s*(\d+)\s*(?:장|편)\s*(\d+)(?:\s*[-~–]\s*(\d+))?\s*(?:장|편|절)?'),
      // "요한복음 3:16-18"
      RegExp(r'([가-힣]+(?:\s?[가-힣]*)?)\s*(\d+)\s*:\s*(\d+)(?:\s*[-~–]\s*(\d+))?'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(q);
      if (match != null) {
        final rawBook = match.group(1)!.trim();
        final chapter = int.parse(match.group(2)!);
        final startV = int.parse(match.group(3)!);
        final endV = match.group(4) != null ? int.parse(match.group(4)!) : startV;

        final fullName = BibleDbService.abbrToFullName(rawBook);
        return _lookupVerse(fullName, chapter, startV, endV);
      }
    }
    return null;
  }

  static Future<List<Verse>> _lookupVerse(
      String book, int chapter, int startV, int endV) async {
    String? text;
    if (startV == endV) {
      text = await BibleDbService.getVerse(book, chapter, startV);
    } else {
      text = await BibleDbService.getVerseRange(book, chapter, startV, endV);
    }

    if (text == null) throw Exception('구절을 찾을 수 없습니다');

    final reference =
        startV == endV ? '$book $chapter:$startV' : '$book $chapter:$startV-$endV';
    return [
      Verse(reference: reference, text: text, mood: 'faith'),
    ];
  }
}
