import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/learned_word.dart';
import '../data/models/level_model.dart';
import '../data/repositories/level_repository.dart';
// Nhớ thêm dòng import TTS này nếu bạn đang dùng chức năng đọc giọng nói nhé
// import '../core/services/tts_service.dart';

class GameProvider extends ChangeNotifier {
  final LevelRepository _repository;
  SharedPreferences? _prefs;

  GameProvider(this._repository);

  LevelModel? currentLevel;
  int currentLevelId = 1;

  List<String> subWordInputs = [];
  List<bool> subWordSolved = [];
  List<LearnedWord> unlockedWords = [];
  List<String> mainWordDisplay = [];

  int selectedSubWordIndex = 0;
  bool isLevelCompleted = false;
  int hints = 3;

  // --- Biến điều khiển rung lắc ---
  int wrongShakeTrigger = 0;
  int errorSubWordIndex = -1;

  // --- THÊM MỚI: Biến quản lý tọa độ bay ---
  Map<String, GlobalKey> sourceKeys = {};
  Map<int, GlobalKey> targetKeys = {};
  FlyingData? currentFlyingData;

  List<int> completedLevels = [];
  int get totalLevels => _repository.totalLevels;
  bool isKeyboardVisible = true;

  // --- HÀM LẤY CHÌA KHÓA TỌA ĐỘ ---
  GlobalKey getSourceKey(int wordIndex, int charIndex) {
    String keyStr = "${wordIndex}_${charIndex}";
    sourceKeys.putIfAbsent(keyStr, () => GlobalKey());
    return sourceKeys[keyStr]!;
  }

  GlobalKey getTargetKey(int targetIndex) {
    targetKeys.putIfAbsent(targetIndex, () => GlobalKey());
    return targetKeys[targetIndex]!;
  }

  // --- 1. KHỞI TẠO & ĐỌC DỮ LIỆU TỪ Ổ CỨNG ---
  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    currentLevelId = _prefs!.getInt('currentLevelId') ?? 1;
    hints = _prefs!.getInt('hints') ?? 3;

    String? wordsJson = _prefs!.getString('unlockedWords');
    if (wordsJson != null) {
      List<dynamic> decoded = json.decode(wordsJson);
      unlockedWords = decoded
          .map((item) => LearnedWord.fromJson(item))
          .toList();
    }

    String? compLevelsJson = _prefs!.getString('completedLevels');
    if (compLevelsJson != null) {
      completedLevels = List<int>.from(json.decode(compLevelsJson));
    }

    await loadLevel(currentLevelId);
  }

  // --- 2. LƯU DỮ LIỆU VÀO Ổ CỨNG ---
  void _saveProgress() {
    if (_prefs == null) return;
    _prefs!.setInt('currentLevelId', currentLevelId);
    _prefs!.setInt('hints', hints);

    List<Map<String, dynamic>> wordsMap = unlockedWords
        .map((w) => w.toJson())
        .toList();
    _prefs!.setString('unlockedWords', json.encode(wordsMap));
    _prefs!.setString('completedLevels', json.encode(completedLevels));
  }

  // --- 3. XÓA TOÀN BỘ DỮ LIỆU (RESET) ---
  Future<void> resetData() async {
    if (_prefs != null) {
      await _prefs!.clear();
    }
    unlockedWords.clear();
    completedLevels.clear();

    currentLevelId = 1;
    hints = 3;
    await loadLevel(1);
  }

  // --- LOGIC SỬ DỤNG GỢI Ý ---
  void useHint() {
    if (hints <= 0 || isLevelCompleted || currentLevel == null) return;
    if (subWordSolved[selectedSubWordIndex]) return;

    String targetWord = currentLevel!.subWords[selectedSubWordIndex].word;
    String currentInput = subWordInputs[selectedSubWordIndex];

    if (currentInput.length < targetWord.length) {
      String nextChar = targetWord[currentInput.length];
      subWordInputs[selectedSubWordIndex] += nextChar.toUpperCase();
      hints--;

      if (subWordInputs[selectedSubWordIndex].length == targetWord.length) {
        _checkSubWordAnswer();
      }

      _saveProgress();
      notifyListeners();
    }
  }

  // --- LOGIC TẢI LEVEL ---
  Future<void> loadLevel(int id) async {
    final nextLevelData = _repository.getLevelById(id);

    if (nextLevelData != null) {
      currentLevelId = id;

      List<String> newSubWordInputs = List.generate(
        nextLevelData.subWords.length,
        (_) => "",
      );
      List<bool> newSubWordSolved = List.generate(
        nextLevelData.subWords.length,
        (_) => false,
      );
      List<String> newMainWordDisplay = List.generate(
        nextLevelData.mainWord.word.length,
        (_) => "",
      );

      currentLevel = nextLevelData;
      subWordInputs = newSubWordInputs;
      subWordSolved = newSubWordSolved;
      mainWordDisplay = newMainWordDisplay;

      selectedSubWordIndex = 0;
      isLevelCompleted = false;
      isKeyboardVisible = true;

      // Xóa điểm neo tọa độ cũ khi qua màn mới
      sourceKeys.clear();
      targetKeys.clear();

      notifyListeners();
    } else {
      print("Không tìm thấy dữ liệu cho Level $id");
    }
  }

  void loadNextLevel() {
    int nextId = currentLevelId + 1;
    if (nextId <= _repository.totalLevels) {
      hints++;
      _saveProgress();
      loadLevel(nextId);
    } else {
      print("Chúc mừng! Bạn đã hoàn thành toàn bộ màn chơi!");
    }
  }

  // --- LOGIC BÀN PHÍM ---
  void hideKeyboard() {
    isKeyboardVisible = false;
    notifyListeners();
  }

  void selectSubWord(int index) {
    selectedSubWordIndex = index;
    isKeyboardVisible = true;
    notifyListeners();
  }

  void inputLetter(String letter) {
    if (currentLevel == null ||
        subWordSolved[selectedSubWordIndex] ||
        isLevelCompleted) {
      return;
    }

    String targetWord = currentLevel!.subWords[selectedSubWordIndex].word;
    String currentInput = subWordInputs[selectedSubWordIndex];

    if (currentInput.length < targetWord.length) {
      subWordInputs[selectedSubWordIndex] += letter.toUpperCase();
      if (subWordInputs[selectedSubWordIndex].length == targetWord.length) {
        _checkSubWordAnswer();
      }
    }
    notifyListeners();
  }

  void deleteLetter() {
    if (subWordInputs[selectedSubWordIndex].isNotEmpty &&
        !subWordSolved[selectedSubWordIndex] &&
        !isLevelCompleted) {
      subWordInputs[selectedSubWordIndex] = subWordInputs[selectedSubWordIndex]
          .substring(0, subWordInputs[selectedSubWordIndex].length - 1);
      notifyListeners();
    } else if (subWordInputs[selectedSubWordIndex].isEmpty &&
        !subWordSolved[selectedSubWordIndex] &&
        !isLevelCompleted) {
      errorSubWordIndex = selectedSubWordIndex;
      wrongShakeTrigger++;
      notifyListeners();
    }
  }

  // --- LOGIC KIỂM TRA ĐÁP ÁN (ĐÃ NÂNG CẤP THÊM HIỆU ỨNG BAY) ---
  void _checkSubWordAnswer() async {
    // Thêm async ở đây
    var subWordData = currentLevel!.subWords[selectedSubWordIndex];

    if (subWordInputs[selectedSubWordIndex] == subWordData.word) {
      // TRƯỜNG HỢP ĐÚNG
      subWordSolved[selectedSubWordIndex] = true;

      // --- LOGIC BAY LÊN ---
      int mapToIndex = subWordData.mapToMainIndex;
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

        Offset startPos = sourceBox.localToGlobal(Offset.zero);
        Offset endPos = targetBox.localToGlobal(Offset.zero);

        currentFlyingData = FlyingData(
          letter: subWordData.charToExtract,
          start: startPos,
          end: endPos,
          startSize: sourceBox.size, // Lấy kích thước ô nhỏ
          endSize: targetBox.size, // Lấy kích thước ô lớn
        );
        notifyListeners(); // Hiện chữ bay

        // Đợi chữ bay xong (600ms)
        await Future.delayed(const Duration(milliseconds: 600));

        currentFlyingData = null; // Tắt chữ bay
      }

      // SAU KHI BAY XONG MỚI GẮN CHỮ VÀO TỪ CHÍNH
      mainWordDisplay[mapToIndex] = subWordData.charToExtract;

      if (!unlockedWords.any((w) => w.word == subWordData.word)) {
        unlockedWords.add(
          LearnedWord(
            word: subWordData.word,
            phonetic: subWordData.details.phonetic,
            definition: subWordData.details.fullDefinition,
            example: subWordData.details.example,
            type: subWordData.details.type,
            translation: subWordData.details.translation,
          ),
        );
        _saveProgress();
      }
      _checkWinCondition();
      notifyListeners(); // Cập nhật lại UI hiển thị chữ chính
    } else {
      // TRƯỜNG HỢP SAI (Rung lắc)
      errorSubWordIndex = selectedSubWordIndex;
      wrongShakeTrigger++;

      subWordInputs[selectedSubWordIndex] = subWordInputs[selectedSubWordIndex]
          .substring(0, subWordInputs[selectedSubWordIndex].length - 1);

      notifyListeners();
    }
  }

  void _checkWinCondition() {
    if (!mainWordDisplay.contains("")) {
      isLevelCompleted = true;
      var mainWord = currentLevel!.mainWord;

      // TTSService.speak(mainWord.word);

      if (!completedLevels.contains(currentLevelId)) {
        completedLevels.add(currentLevelId);
      }

      if (!unlockedWords.any((w) => w.word == mainWord.word)) {
        unlockedWords.insert(
          0,
          LearnedWord(
            word: mainWord.word,
            phonetic: mainWord.phonetic,
            definition: mainWord.definition,
            example: mainWord.example,
            type: "Target Word",
            translation: mainWord.translation,
          ),
        );
      }
      _saveProgress();
      notifyListeners();
    }
  }
}

// LỚP CHỨA DỮ LIỆU BAY NẰM NGOÀI CÙNG
class FlyingData {
  final String letter;
  final Offset start;
  final Offset end;
  final Size startSize; // Kích thước lúc xuất phát
  final Size endSize; // Kích thước lúc hạ cánh

  FlyingData({
    required this.letter,
    required this.start,
    required this.end,
    required this.startSize,
    required this.endSize,
  });
}
