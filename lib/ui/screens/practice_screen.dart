import 'dart:async'; // Bổ sung thư viện để dùng Timer

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../../logic/practice_provider.dart';
import 'practice_result_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({Key? key}) : super(key: key);

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  bool _hasAnswered = false;
  bool _isCorrect = false;
  String? _selectedMultipleChoice;
  Timer? _autoAdvanceTimer; // Timer đếm ngược 2s

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PracticeProvider>(context, listen: false);
      if (provider.selectedType == ExerciseType.listening) {
        _speakCurrentWord(provider.currentQuestion.wordData.word);
      }
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakCurrentWord(String word) async {
    await _flutterTts.speak(word);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _textController.dispose();
    _autoAdvanceTimer?.cancel(); // Hủy timer nếu người dùng thoát màn hình
    super.dispose();
  }

  // --- HÀM NỘP ĐÁP ÁN ---
  void _submitAnswer(PracticeProvider provider) {
    if (_hasAnswered) return;

    String answer = provider.selectedType == ExerciseType.multipleChoice
        ? (_selectedMultipleChoice ?? "")
        : _textController.text;

    if (answer.trim().isEmpty) return;

    setState(() {
      _isCorrect = provider.checkAnswer(answer);
      _hasAnswered = true;
    });

    // 👉 LOGIC TỰ ĐỘNG CHUYỂN CÂU SAU 2 GIÂY NẾU ĐÚNG
    if (_isCorrect) {
      _autoAdvanceTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _nextQuestion(provider);
        }
      });
    }
  }

  // --- HÀM CHUYỂN CÂU TIẾP THEO ---
  void _nextQuestion(PracticeProvider provider) {
    _autoAdvanceTimer?.cancel(); // Hủy timer đề phòng người dùng bấm tay

    provider.nextQuestion();
    if (provider.isFinished) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PracticeResultScreen(
            score: provider.score,
            totalQuestions: provider.questions.length,
            questions: provider.questions,
          ),
        ),
      );
    } else {
      setState(() {
        _hasAnswered = false;
        _isCorrect = false;
        _selectedMultipleChoice = null;
        _textController.clear();
      });

      if (provider.selectedType == ExerciseType.listening) {
        _speakCurrentWord(provider.currentQuestion.wordData.word);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<PracticeProvider>(
      builder: (context, provider, child) {
        if (provider.questions.isEmpty)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        final currentQ = provider.currentQuestion;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
            title: LinearProgressIndicator(
              value: (provider.currentIndex + 1) / provider.questions.length,
              backgroundColor: theme.colorScheme.surfaceVariant,
              color: theme.colorScheme.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    '${provider.currentIndex + 1}/${provider.questions.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildExerciseContent(currentQ, provider, theme),
                ),
                _buildFeedbackAndButton(provider, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseContent(
    QuizQuestion question,
    PracticeProvider provider,
    ThemeData theme,
  ) {
    switch (provider.selectedType) {
      case ExerciseType.multipleChoice:
        return _buildMultipleChoice(question, theme);
      case ExerciseType.listening:
        return _buildListening(question, theme);
      case ExerciseType.writing:
        return _buildWriting(question, theme);
    }
  }

  // 1. TRẮC NGHIỆM
  Widget _buildMultipleChoice(QuizQuestion question, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chọn nghĩa đúng của từ sau:',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          question.wordData.word,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          question.wordData.phonetic,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 40),
        ...question.options
            .map((option) => _buildOptionCard(option, theme))
            .toList(),
      ],
    );
  }

  Widget _buildOptionCard(String optionText, ThemeData theme) {
    bool isSelected = _selectedMultipleChoice == optionText;
    bool isCorrectAnswer =
        optionText ==
        Provider.of<PracticeProvider>(
          context,
          listen: false,
        ).currentQuestion.wordData.translation;

    Color cardColor = theme.cardColor;
    Color borderColor = theme.dividerColor;

    if (_hasAnswered) {
      if (isCorrectAnswer) {
        cardColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
      } else if (isSelected && !isCorrectAnswer) {
        cardColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
      cardColor = theme.colorScheme.primaryContainer.withOpacity(0.3);
    }

    return GestureDetector(
      onTap: _hasAnswered
          ? null
          : () => setState(() => _selectedMultipleChoice = optionText),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                optionText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (_hasAnswered && isCorrectAnswer)
              const Icon(Icons.check_circle, color: Colors.green),
            if (_hasAnswered && isSelected && !isCorrectAnswer)
              const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }

  // 2. NGHE
  Widget _buildListening(QuizQuestion question, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Nghe và gõ lại từ Tiếng Anh',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () => _speakCurrentWord(question.wordData.word),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.volume_up_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 40),
        _buildTextField(theme),
      ],
    );
  }

  // 3. VIẾT (Đã cập nhật giao diện cực đẹp)
  Widget _buildWriting(QuizQuestion question, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Viết từ Tiếng Anh có nghĩa sau:',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          question.wordData.translation,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Text(
            question.wordData.phonetic,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            question.wordData.definitionVi,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        _buildTextField(theme),
      ],
    );
  }

  Widget _buildTextField(ThemeData theme) {
    return TextField(
      controller: _textController,
      enabled: !_hasAnswered,
      textAlign: TextAlign.center,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) =>
          _submitAnswer(Provider.of<PracticeProvider>(context, listen: false)),
      decoration: InputDecoration(
        hintText: 'Nhập từ vựng...',
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  // --- KHU VỰC PHẢN HỒI & NÚT BẤM (BOTTOM) ---
  Widget _buildFeedbackAndButton(PracticeProvider provider, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasAnswered)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _isCorrect ? Colors.green : Colors.red),
            ),
            child: Column(
              children: [
                Text(
                  _isCorrect
                      ? 'Tuyệt vời! Chính xác.'
                      : 'Rất tiếc! Đáp án đúng là:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 👉 HIỂN THỊ ĐÁP ÁN ĐÚNG KHI TRẢ LỜI SAI
                if (!_isCorrect) ...[
                  const SizedBox(height: 8),
                  Text(
                    provider.correctAnswerString, // Lấy đáp án đúng từ Provider
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

        // Nếu trả lời ĐÚNG -> Nút biến thành Loading (Vì đã có Timer tự chuyển)
        // Nếu trả lời SAI -> Hiện nút "ĐÃ HIỂU, TIẾP TỤC" để người chơi tự bấm
        if (!_hasAnswered || !_isCorrect)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: _hasAnswered
                  ? Colors.red
                  : theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              if (_hasAnswered) {
                _nextQuestion(provider);
              } else {
                _submitAnswer(provider);
              }
            },
            child: Text(
              _hasAnswered ? 'ĐÃ HIỂU, TIẾP TỤC' : 'KIỂM TRA',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          )
        else
          // Giao diện chờ khi trả lời đúng
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'ĐANG CHUYỂN CÂU...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
