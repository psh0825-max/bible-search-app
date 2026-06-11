class Verse {
  final String reference;
  final String text;
  final String reason;
  final String mood;

  const Verse({
    required this.reference,
    required this.text,
    this.reason = '',
    this.mood = 'faith',
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      reference: json['reference'] ?? '',
      text: json['text'] ?? '',
      reason: json['reason'] ?? '',
      mood: json['mood'] ?? 'faith',
    );
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'text': text,
        'reason': reason,
        'mood': mood,
      };

  /// "시편 23:1" → "시편 23편 1절"
  /// "요한복음 3:16-18" → "요한복음 3장 16-18절"
  String get formattedReference {
    final match = RegExp(r'^(.+?)\s+(\d+):(.+)$').firstMatch(reference);
    if (match == null) return reference;
    final book = match.group(1)!;
    final chapter = match.group(2)!;
    final versesPart = match.group(3)!;
    final unit = book == '시편' ? '편' : '장';
    return '$book $chapter$unit $versesPart절';
  }
}
