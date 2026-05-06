class BibleBook {
  final int volume; // 1-66
  final String name;
  final String abbr;
  final int chapterCount;
  final bool isOldTestament;

  const BibleBook({
    required this.volume,
    required this.name,
    required this.abbr,
    required this.chapterCount,
    required this.isOldTestament,
  });

  String get testament => isOldTestament ? '구약' : '신약';
}
