class Bookmark {
  final String id;
  final String reference;
  final String text;
  final String reason;
  final String mood;
  final DateTime createdAt;
  final String? note;
  final int? highlightColor; // ARGB color value

  const Bookmark({
    required this.id,
    required this.reference,
    required this.text,
    this.reason = '',
    this.mood = 'faith',
    required this.createdAt,
    this.note,
    this.highlightColor,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      text: json['text'] ?? '',
      reason: json['reason'] ?? '',
      mood: json['mood'] ?? 'faith',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      note: json['note'],
      highlightColor: json['highlightColor'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'text': text,
        'reason': reason,
        'mood': mood,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
        'highlightColor': highlightColor,
      };

  Bookmark copyWith({
    String? note,
    int? highlightColor,
  }) {
    return Bookmark(
      id: id,
      reference: reference,
      text: text,
      reason: reason,
      mood: mood,
      createdAt: createdAt,
      note: note ?? this.note,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }
}
