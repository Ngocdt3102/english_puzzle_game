import 'dart:math';

import 'package:flutter/material.dart';

import '../data/models/learned_word.dart';

// --- CÁC ENUM ĐIỀU KHIỂN CẤU HÌNH ---
enum PracticeScope { all, byTopic }

enum ExerciseType {
  multipleChoice, // Trắc nghiệm (Anh -> Việt)
  listening, // Nghe (TTS -> Anh)
  writing, // Viết (Việt + IPA -> Anh)
}

// --- MODEL CÂU HỎI ---
class QuizQuestion {
  final LearnedWord wordData;
  final List<String> options; // Chỉ dùng cho Multiple Choice

  QuizQuestion({required this.wordData, this.options = const []});
}

class PracticeProvider extends ChangeNotifier {
  // ĐIỀU KIỆN MỞ KHÓA LUYỆN TẬP
  static const int minWordsToUnlock = 30;

  // Trạng thái cấu hình
  PracticeScope selectedScope = PracticeScope.all;
  String? selectedTopic;
  ExerciseType selectedType = ExerciseType.multipleChoice;

  // Trạng thái phiên luyện tập
  List<QuizQuestion> questions = [];
  int currentIndex = 0;
  int score = 0;
  bool isFinished = false;

  final Random _random = Random();

  // --- GETTER TIỆN ÍCH ---
  QuizQuestion get currentQuestion => questions[currentIndex];

  // 👉 THÊM MỚI: Lấy chuỗi đáp án đúng để hiển thị khi người chơi trả lời sai
  String get correctAnswerString {
    if (selectedType == ExerciseType.multipleChoice) {
      return currentQuestion
          .wordData
          .translation; // Trắc nghiệm: Cần hiện nghĩa Tiếng Việt
    } else {
      return currentQuestion.wordData.word; // Nghe/Viết: Cần hiện từ Tiếng Anh
    }
  }

  // --- 1. CẬP NHẬT CẤU HÌNH ---
  void setScope(PracticeScope scope) {
    selectedScope = scope;
    notifyListeners();
  }

  void setTopic(String topic) {
    selectedTopic = topic;
    notifyListeners();
  }

  void setType(ExerciseType type) {
    selectedType = type;
    notifyListeners();
  }

  // --- 2. HÀM KHỞI TẠO BÀI LUYỆN TẬP ---
  void startPractice(List<LearnedWord> allUnlockedWords) {
    List<LearnedWord> pool = List.from(allUnlockedWords);

    if (selectedScope == PracticeScope.byTopic && selectedTopic != null) {
      pool = pool.where((w) => w.topic == selectedTopic).toList();
    }

    if (pool.isEmpty) return;

    pool.shuffle(_random);
    List<LearnedWord> selectedWords = pool.take(min(30, pool.length)).toList();

    questions = selectedWords.map((word) {
      List<String> options = [];

      if (selectedType == ExerciseType.multipleChoice) {
        options.add(word.translation);

        List<LearnedWord> distractorPool = allUnlockedWords
            .where((w) => w.word != word.word)
            .toList();
        distractorPool.shuffle(_random);

        for (var i = 0; i < min(3, distractorPool.length); i++) {
          options.add(distractorPool[i].translation);
        }

        options.shuffle(_random);
      }

      return QuizQuestion(wordData: word, options: options);
    }).toList();

    currentIndex = 0;
    score = 0;
    isFinished = false;
    notifyListeners();
  }

  // --- 3. KIỂM TRA ĐÁP ÁN ---
  bool checkAnswer(String userInput) {
    bool correct = false;
    final currentWord = questions[currentIndex].wordData;

    if (selectedType == ExerciseType.multipleChoice) {
      correct = userInput == currentWord.translation;
    } else {
      correct =
          userInput.trim().toUpperCase() == currentWord.word.toUpperCase();
    }

    if (correct) score++;
    return correct;
  }

  // --- 4. ĐIỀU HƯỚNG ---
  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
    } else {
      isFinished = true;
    }
    notifyListeners();
  }

  // --- 5. RESET ---
  void reset() {
    questions = [];
    isFinished = false;
    notifyListeners();
  }
}
