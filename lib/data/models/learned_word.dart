class LearnedWord {
  final String word;
  final String phonetic;
  final String definition;
  final String example;
  final String type;
  final String translation; // --- MỚI THÊM ---

  LearnedWord({
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.example,
    required this.type,
    required this.translation, // --- MỚI THÊM ---
  });

  // Chuyển Object thành Map để lưu vào bộ nhớ máy (SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'phonetic': phonetic,
      'definition': definition,
      'example': example,
      'type': type,
      'translation': translation, // --- MỚI THÊM ---
    };
  }

  // Khôi phục Object từ Map khi mở lại App
  factory LearnedWord.fromJson(Map<String, dynamic> json) {
    return LearnedWord(
      word: json['word'],
      phonetic: json['phonetic'],
      definition: json['definition'],
      example: json['example'],
      type: json['type'],
      // Dùng ?? '' để bảo vệ App không bị văng khi đọc dữ liệu cũ đã lưu từ trước
      translation: json['translation'] ?? '', // --- MỚI THÊM ---
    );
  }
}
