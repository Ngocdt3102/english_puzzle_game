class LevelModel {
  final int levelId;
  final String difficulty;
  final MainWord mainWord;
  final List<SubWord> subWords;

  LevelModel({
    required this.levelId,
    required this.difficulty,
    required this.mainWord,
    required this.subWords,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      levelId: json['level_id'],
      difficulty: json['difficulty'] ?? 'A1', // Gắn mặc định nếu thiếu
      mainWord: MainWord.fromJson(json['main_word']),
      subWords: (json['sub_words'] as List)
          .map((item) => SubWord.fromJson(item))
          .toList(),
    );
  }
}

class MainWord {
  final String word;
  final String type; // --- MỚI: Từ loại ---
  final String phonetic;
  final String definition;
  final String definitionVi; // --- MỚI: Định nghĩa tiếng Việt ---
  final String example;
  final String exampleVi; // --- MỚI: Ví dụ tiếng Việt ---
  final String translation;
  final List<String> synonyms; // --- MỚI ---
  final List<String> antonyms; // --- MỚI ---
  final String audioFile; // --- MỚI ---

  MainWord({
    required this.word,
    required this.type,
    required this.phonetic,
    required this.definition,
    required this.definitionVi,
    required this.example,
    required this.exampleVi,
    required this.translation,
    required this.synonyms,
    required this.antonyms,
    required this.audioFile,
  });

  factory MainWord.fromJson(Map<String, dynamic> json) {
    return MainWord(
      word: json['word'].toString().toUpperCase(),
      type: json['type'] ?? 'Noun',
      phonetic: json['phonetic'] ?? '',
      definition: json['definition'] ?? '',
      definitionVi: json['definition_vi'] ?? '',
      example: json['example'] ?? '',
      exampleVi: json['example_vi'] ?? '',
      translation: json['translation'] ?? '',
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
      audioFile: json['audio_file'] ?? '',
    );
  }
}

class SubWord {
  final String word;
  final String clue;
  final String charToExtract;
  final int extractIndex;
  final int mapToMainIndex;
  final WordDetails details;

  SubWord({
    required this.word,
    required this.clue,
    required this.charToExtract,
    required this.extractIndex,
    required this.mapToMainIndex,
    required this.details,
  });

  factory SubWord.fromJson(Map<String, dynamic> json) {
    return SubWord(
      word: json['word'].toString().toUpperCase(),
      clue: json['clue_for_game'] ?? '',
      charToExtract: json['char_to_extract'].toString().toUpperCase(),
      extractIndex: json['extract_index'],
      mapToMainIndex: json['map_to_main_index'],
      details: WordDetails.fromJson(json['details']),
    );
  }
}

class WordDetails {
  final String type;
  final String phonetic;
  final String fullDefinition;
  final String fullDefinitionVi; // --- MỚI: Định nghĩa tiếng Việt ---
  final String example;
  final String exampleVi; // --- MỚI: Ví dụ tiếng Việt ---
  final String translation;
  final List<String> synonyms; // --- MỚI ---
  final List<String> antonyms; // --- MỚI ---

  WordDetails({
    required this.type,
    required this.phonetic,
    required this.fullDefinition,
    required this.fullDefinitionVi,
    required this.example,
    required this.exampleVi,
    required this.translation,
    required this.synonyms,
    required this.antonyms,
  });

  factory WordDetails.fromJson(Map<String, dynamic> json) {
    return WordDetails(
      type: json['type'] ?? '',
      phonetic: json['phonetic'] ?? '',
      fullDefinition: json['full_definition'] ?? '',
      fullDefinitionVi: json['full_definition_vi'] ?? '',
      example: json['example'] ?? '',
      exampleVi: json['example_vi'] ?? '',
      translation: json['translation'] ?? '',
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
    );
  }
}
