class LearnedWord {
  final String word;
  final String topic;
  final String phonetic;
  final String type;
  final String definition;
  final String definitionVi; // --- MỚI: Định nghĩa tiếng Việt ---
  final String example;
  final String exampleVi; // --- MỚI: Ví dụ tiếng Việt ---
  final String translation;
  final List<String> synonyms; // --- MỚI: Từ đồng nghĩa ---
  final List<String> antonyms; // --- MỚI: Từ trái nghĩa ---
  final String audioFile; // --- MỚI: Đường dẫn âm thanh (nếu có) ---

  LearnedWord({
    required this.word,
    required this.topic,
    required this.phonetic,
    required this.type,
    required this.definition,
    required this.definitionVi,
    required this.example,
    required this.exampleVi,
    required this.translation,
    required this.synonyms,
    required this.antonyms,
    required this.audioFile,
  });

  // Chuyển Object thành Map để lưu vào SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'topic': topic,
      'phonetic': phonetic,
      'type': type,
      'definition': definition,
      'definition_vi': definitionVi,
      'example': example,
      'example_vi': exampleVi,
      'translation': translation,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'audio_file': audioFile,
    };
  }

  // Khôi phục Object từ Map (Bảo vệ an toàn bằng ?? cho các dữ liệu cũ của V1)
  factory LearnedWord.fromJson(Map<String, dynamic> json) {
    return LearnedWord(
      word: json['word'] ?? '',
      topic: json['topic'] ?? 'General',
      phonetic: json['phonetic'] ?? '',
      type: json['type'] ?? '',
      definition: json['definition'] ?? '',
      // Nếu user đang có data cũ không có tiếng Việt, mặc định là chuỗi rỗng
      definitionVi: json['definition_vi'] ?? '',
      example: json['example'] ?? '',
      exampleVi: json['example_vi'] ?? '',
      translation: json['translation'] ?? '',
      // Ép kiểu an toàn cho List, nếu null thì trả về mảng rỗng []
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
      audioFile: json['audio_file'] ?? '',
    );
  }
}
