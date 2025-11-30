class DictionaryEntry {
  const DictionaryEntry({
    required this.id,
    required this.englishWord,
    required this.myanmarMeaning,
    this.example,
  });

  final int id;
  final String englishWord;
  final String myanmarMeaning;
  final String? example;

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      id: json['id'] as int,
      englishWord: json['english_word']?.toString() ?? '',
      myanmarMeaning: json['myanmar_meaning']?.toString() ?? '',
      example: json['example']?.toString(),
    );
  }
}

