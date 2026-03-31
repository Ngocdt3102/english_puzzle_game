import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/learned_word.dart';
import '../data/models/level_model.dart';
import '../data/repositories/level_repository.dart';

class GameProvider extends ChangeNotifier {
  final LevelRepository _repository;
  SharedPreferences? _prefs;

  GameProvider(this._repository);

  // --- QUẢN LÝ CHỦ ĐỀ & TIẾN ĐỘ ---
  String currentTopicId = "";
  List<String> completedLevels = []; // Lưu kiểu "TOPICID_LEVELID"

  // --- DỮ LIỆU MÀN CHƠI HIỆN TẠI ---
  LevelModel? currentLevel;
  int currentLevelId = 1;
  List<String> subWordInputs = [];
  List<bool> subWordSolved = [];
  List<LearnedWord> unlockedWords = [];
  List<String> mainWordDisplay = [];

  // --- TRẠNG THÁI GAME ---
  int selectedSubWordIndex = 0;
  bool isLevelCompleted = false;
  bool isKeyboardVisible = true;

  // --- HỆ THỐNG KINH TẾ (COINS & HINTS) ---
  int hints = 3;
  int coins = 50;
  int hintsUsedThisLevel = 0;
  List<bool> hintUsedOnSubWord = [];
  int lastCoinsEarned = 0;

  // --- HIỆU ỨNG & KEY ---
  int wrongShakeTrigger = 0;
  int errorSubWordIndex = -1;
  Map<String, GlobalKey> sourceKeys = {};
  Map<int, GlobalKey> targetKeys = {};
  FlyingData? currentFlyingData;

  // --- GETTERS ---
  int get totalLevels => _repository.totalLevels;
  List<LevelModel> get currentTopicLevels => _repository.currentLevels;

  // --- QUẢN LÝ TỌA ĐỘ ---
  GlobalKey getSourceKey(int wordIndex, int charIndex) {
    String keyStr = "${wordIndex}_$charIndex";
    sourceKeys.putIfAbsent(keyStr, () => GlobalKey());
    return sourceKeys[keyStr]!;
  }

  GlobalKey getTargetKey(int targetIndex) {
    targetKeys.putIfAbsent(targetIndex, () => GlobalKey());
    return targetKeys[targetIndex]!;
  }

  // --- 1. KHỞI TẠO DỮ LIỆU ---
  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    currentLevelId = _prefs!.getInt('currentLevelId') ?? 1;
    hints = _prefs!.getInt('hints') ?? 3;
    coins = _prefs!.getInt('coins') ?? 50;

    String? wordsJson = _prefs!.getString('unlockedWords');
    if (wordsJson != null) {
      List<dynamic> decoded = json.decode(wordsJson);
      unlockedWords = decoded
          .map((item) => LearnedWord.fromJson(item))
          .toList();
    }

    String? compLevelsJson = _prefs!.getString('completedLevels');
    if (compLevelsJson != null) {
      List<dynamic> decoded = json.decode(compLevelsJson);
      completedLevels = decoded.map((e) => e.toString()).toList();
    }
  }

  // --- 2. LƯU DỮ LIỆU ---
  void _saveProgress() {
    if (_prefs == null) return;
    _prefs!.setInt('currentLevelId', currentLevelId);
    _prefs!.setInt('hints', hints);
    _prefs!.setInt('coins', coins);

    List<Map<String, dynamic>> wordsMap = unlockedWords
        .map((w) => w.toJson())
        .toList();
    _prefs!.setString('unlockedWords', json.encode(wordsMap));
    _prefs!.setString('completedLevels', json.encode(completedLevels));
  }

  // --- 3. RESET DATA ---
  Future<void> resetData() async {
    if (_prefs != null) await _prefs!.clear();
    unlockedWords.clear();
    completedLevels.clear();
    currentLevelId = 1;
    hints = 3;
    coins = 50;
    // Không gọi loadLevel(1) ở đây vì chưa có Topic nạp vào, tránh lỗi crash
    notifyListeners();
  }

  // --- 4. LOGIC CHƠI GAME ---
  void useHint() {
    if (hints <= 0 || isLevelCompleted || currentLevel == null) return;
    if (subWordSolved[selectedSubWordIndex]) return;

    String targetWord = currentLevel!.subWords[selectedSubWordIndex].word;
    String currentInput = subWordInputs[selectedSubWordIndex];

    if (currentInput.length < targetWord.length) {
      String nextChar = targetWord[currentInput.length];
      subWordInputs[selectedSubWordIndex] += nextChar.toUpperCase();

      hints--;
      hintsUsedThisLevel++;
      hintUsedOnSubWord[selectedSubWordIndex] = true;

      if (subWordInputs[selectedSubWordIndex].length == targetWord.length) {
        _checkSubWordAnswer();
      }

      _saveProgress();
      notifyListeners();
    }
  }

  Future<void> loadLevel(int id) async {
    final nextLevelData = _repository.getLevelById(id);
    if (nextLevelData != null) {
      currentLevelId = id;
      currentLevel = nextLevelData;

      subWordInputs = List.generate(nextLevelData.subWords.length, (_) => "");
      subWordSolved = List.generate(
        nextLevelData.subWords.length,
        (_) => false,
      );
      mainWordDisplay = List.generate(
        nextLevelData.mainWord.word.length,
        (_) => "",
      );

      hintUsedOnSubWord = List.generate(
        nextLevelData.subWords.length,
        (_) => false,
      );
      hintsUsedThisLevel = 0;
      lastCoinsEarned = 0;

      selectedSubWordIndex = 0;
      isLevelCompleted = false;
      isKeyboardVisible = true;
      sourceKeys.clear();
      targetKeys.clear();
      notifyListeners();
    }
  }

  // --- 5. LOGIC THƯỞNG COIN & MỐC ---
  int _getMilestoneReward(int milestoneIndex) {
    if (milestoneIndex == 1) return 20;
    int reward = 20;
    for (int i = 2; i <= milestoneIndex; i++) {
      reward = (reward * 2) + 10;
    }
    return reward;
  }

  void _checkWinCondition() {
    if (!mainWordDisplay.contains("")) {
      isLevelCompleted = true;
      String progressKey = "${currentTopicId}_$currentLevelId";

      if (!completedLevels.contains(progressKey)) {
        completedLevels.add(progressKey);

        int earned = 0;
        if (hintsUsedThisLevel == 0)
          earned += 20;
        else if (hintsUsedThisLevel == 1)
          earned += 18;
        else if (hintsUsedThisLevel == 2)
          earned += 15;
        else if (hintsUsedThisLevel == 3)
          earned += 10;

        for (bool used in hintUsedOnSubWord) {
          earned += used ? 2 : 5;
        }

        int totalComp = completedLevels.length;
        if (totalComp > 0 && totalComp % 5 == 0) {
          earned += _getMilestoneReward(totalComp ~/ 5);
        }

        coins += earned;
        lastCoinsEarned = earned;
      }

      var mainWord = currentLevel!.mainWord;
      if (!unlockedWords.any((w) => w.word == mainWord.word)) {
        unlockedWords.insert(
          0,
          LearnedWord(
            word: mainWord.word,
            topic: _repository.currentTopicName,
            phonetic: mainWord.phonetic,
            type: mainWord.type,
            definition: mainWord.definition,
            definitionVi: mainWord.definitionVi,
            example: mainWord.example,
            exampleVi: mainWord.exampleVi,
            translation: mainWord.translation,
            synonyms: mainWord.synonyms,
            antonyms: mainWord.antonyms,
            audioFile: mainWord.audioFile,
          ),
        );
      }
      _saveProgress();
      notifyListeners();
    }
  }

  // --- 6. HÀM LOAD TOPIC ĐA NĂNG ---
  Future<void> loadTopicData(String topicId, String fileName) async {
    currentTopicId = topicId;
    await _repository.loadTopic(fileName);

    final levels = _repository.currentLevels;
    int highestCompletedIndex = -1;

    for (int i = 0; i < levels.length; i++) {
      if (completedLevels.contains("${currentTopicId}_${levels[i].levelId}")) {
        highestCompletedIndex = i;
      }
    }

    int nextLevelToLoad;
    if (highestCompletedIndex == -1) {
      nextLevelToLoad = levels.first.levelId;
    } else if (highestCompletedIndex < levels.length - 1) {
      nextLevelToLoad = levels[highestCompletedIndex + 1].levelId;
    } else {
      nextLevelToLoad = levels.last.levelId;
    }

    await loadLevel(nextLevelToLoad);
  }

  void loadNextLevel() {
    final currentIndex = _repository.currentLevels.indexWhere(
      (l) => l.levelId == currentLevelId,
    );
    if (currentIndex != -1 &&
        currentIndex < _repository.currentLevels.length - 1) {
      loadLevel(_repository.currentLevels[currentIndex + 1].levelId);
    }
  }

  // --- 7. CỬA HÀNG (STORE) ---
  bool buyItem(int cost, int hintAmount) {
    if (coins >= cost) {
      coins -= cost;
      hints += hintAmount;
      _saveProgress();
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- 8. LOGIC GIAO DIỆN ---
  void hideKeyboard() {
    isKeyboardVisible = false;
    notifyListeners();
  }

  void selectSubWord(int index) {
    selectedSubWordIndex = index;
    isKeyboardVisible = true;
    notifyListeners();
  }

  // --- TỰ ĐỘNG CHUYỂN QUA TỪ PHỤ TIẾP THEO ---
  void _autoSelectNextSubWord() {
    int nextIndex = -1;
    // Tìm từ sau index hiện tại
    for (int i = selectedSubWordIndex + 1; i < subWordSolved.length; i++) {
      if (!subWordSolved[i]) {
        nextIndex = i;
        break;
      }
    }
    // Nếu không thấy, quay lại tìm từ đầu danh sách
    if (nextIndex == -1) {
      for (int i = 0; i < selectedSubWordIndex; i++) {
        if (!subWordSolved[i]) {
          nextIndex = i;
          break;
        }
      }
    }

    if (nextIndex != -1) {
      selectedSubWordIndex = nextIndex;
      isKeyboardVisible = true;
    }
  }

  void inputLetter(String letter) {
    if (currentLevel == null ||
        subWordSolved[selectedSubWordIndex] ||
        isLevelCompleted)
      return;
    String targetWord = currentLevel!.subWords[selectedSubWordIndex].word;
    if (subWordInputs[selectedSubWordIndex].length < targetWord.length) {
      subWordInputs[selectedSubWordIndex] += letter.toUpperCase();
      if (subWordInputs[selectedSubWordIndex].length == targetWord.length) {
        _checkSubWordAnswer();
      }
    }
    notifyListeners();
  }

  void deleteLetter() {
    if (subWordInputs[selectedSubWordIndex].isNotEmpty &&
        !subWordSolved[selectedSubWordIndex]) {
      subWordInputs[selectedSubWordIndex] = subWordInputs[selectedSubWordIndex]
          .substring(0, subWordInputs[selectedSubWordIndex].length - 1);
      notifyListeners();
    } else {
      errorSubWordIndex = selectedSubWordIndex;
      wrongShakeTrigger++;
      notifyListeners();
    }
  }

  void _checkSubWordAnswer() async {
    var subWordData = currentLevel!.subWords[selectedSubWordIndex];
    if (subWordInputs[selectedSubWordIndex] == subWordData.word) {
      subWordSolved[selectedSubWordIndex] = true;
      int mapToIndex = subWordData.mapToMainIndex;

      // Xử lý animation bay
      GlobalKey sourceKey = getSourceKey(
        selectedSubWordIndex,
        subWordData.extractIndex,
      );
      GlobalKey targetKey = getTargetKey(mapToIndex);

      if (sourceKey.currentContext != null &&
          targetKey.currentContext != null) {
        RenderBox sourceBox =
            sourceKey.currentContext!.findRenderObject() as RenderBox;
        RenderBox targetBox =
            targetKey.currentContext!.findRenderObject() as RenderBox;
        currentFlyingData = FlyingData(
          letter: subWordData.charToExtract,
          start: sourceBox.localToGlobal(Offset.zero),
          end: targetBox.localToGlobal(Offset.zero),
          startSize: sourceBox.size,
          endSize: targetBox.size,
        );
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 600));
        currentFlyingData = null;
      }

      mainWordDisplay[mapToIndex] = subWordData.charToExtract;

      // Thêm từ phụ vào kho từ vựng
      if (!unlockedWords.any((w) => w.word == subWordData.word)) {
        unlockedWords.add(
          LearnedWord(
            word: subWordData.word,
            topic: _repository.currentTopicName,
            phonetic: subWordData.details.phonetic,
            type: subWordData.details.type,
            definition: subWordData.details.fullDefinition,
            definitionVi: subWordData.details.fullDefinitionVi,
            example: subWordData.details.example,
            exampleVi: subWordData.details.exampleVi,
            translation: subWordData.details.translation,
            synonyms: subWordData.details.synonyms,
            antonyms: subWordData.details.antonyms,
            audioFile: '',
          ),
        );
      }

      // TỰ ĐỘNG CHUYỂN TỪ
      _autoSelectNextSubWord();

      _checkWinCondition();
      _saveProgress();
      notifyListeners();
    } else {
      errorSubWordIndex = selectedSubWordIndex;
      wrongShakeTrigger++;
      subWordInputs[selectedSubWordIndex] = subWordInputs[selectedSubWordIndex]
          .substring(0, subWordInputs[selectedSubWordIndex].length - 1);
      notifyListeners();
    }
  }
}

class FlyingData {
  final String letter;
  final Offset start;
  final Offset end;
  final Size startSize;
  final Size endSize;
  FlyingData({
    required this.letter,
    required this.start,
    required this.end,
    required this.startSize,
    required this.endSize,
  });
}
