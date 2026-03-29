class LevelModel {
  final int levelId;
  final String theme;
  final String difficulty;
  final MainWord mainWord;
  final List<SubWord> subWords;

  LevelModel({
    required this.levelId,
    required this.theme,
    required this.difficulty,
    required this.mainWord,
    required this.subWords,
  });

  // Chuyển đổi từ JSON sang Object LevelModel
  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      levelId: json['level_id'],
      theme: json['theme'],
      difficulty: json['difficulty'],
      mainWord: MainWord.fromJson(json['main_word']),
      subWords: (json['sub_words'] as List)
          .map((item) => SubWord.fromJson(item))
          .toList(),
    );
  }
}

class MainWord {
  final String word;
  final String phonetic;
  final String definition;
  final String example;

  MainWord({
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.example,
  });

  factory MainWord.fromJson(Map<String, dynamic> json) {
    return MainWord(
      word: json['word']
          .toString()
          .toUpperCase(), // Đảm bảo luôn viết hoa để so khớp
      phonetic: json['phonetic'],
      definition: json['definition'],
      example: json['example'],
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
      clue: json['clue_for_game'],
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
  final String example;

  WordDetails({
    required this.type,
    required this.phonetic,
    required this.fullDefinition,
    required this.example,
  });

  factory WordDetails.fromJson(Map<String, dynamic> json) {
    return WordDetails(
      type: json['type'],
      phonetic: json['phonetic'],
      fullDefinition: json['full_definition'],
      example: json['example'],
    );
  }
}
