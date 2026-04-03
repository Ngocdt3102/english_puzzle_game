import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/practice_provider.dart';

class PracticeResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<QuizQuestion> questions;

  const PracticeResultScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Tính toán Tỉ lệ %
    final double percentage = totalQuestions > 0 ? score / totalQuestions : 0;
    final int percentInt = (percentage * 100).round();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // SafeArea để không lẹm vào tai thỏ/status bar
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. PHẦN HEADER: VÒNG TRÒN % ĐIỂM SỐ ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'TỔNG KẾT LUYỆN TẬP',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Hiệu ứng vòng tròn % chạy mượt mà
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: percentage),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 12,
                              backgroundColor: theme.dividerColor.withOpacity(
                                0.5,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(value * 100).round()}%',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '$score / $totalQuestions đúng',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 2. PHẦN BODY: DANH SÁCH TỪ VỰNG ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Từ vựng đã ôn tập',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final wordData = questions[index].wordData;
                  return _buildWordTile(wordData, theme);
                },
              ),
            ),

            // --- 3. PHẦN FOOTER: NÚT ĐIỀU HƯỚNG ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // Nút Về Màn Hình Chọn Chế Độ (Lùi 2 bước)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: BorderSide(color: colorScheme.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        // Reset Provider trước khi thoát
                        Provider.of<PracticeProvider>(
                          context,
                          listen: false,
                        ).reset();

                        // Pop 2 lần để qua mặt màn hình Setup, lùi thẳng về Mode Selection
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.dashboard_customize_rounded,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Nút Ôn tập tiếp (Lùi 1 bước về màn Setup)
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        // Reset Provider
                        Provider.of<PracticeProvider>(
                          context,
                          listen: false,
                        ).reset();

                        // Lùi đúng 1 bước về màn hình PracticeSetupScreen đang nằm ngay bên dưới
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'LUYỆN TẬP TIẾP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị 1 từ vựng trong danh sách
  Widget _buildWordTile(dynamic wordData, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng 1: Từ tiếng Anh + Từ loại
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                wordData.word,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              // Tag Từ loại (Ví dụ: [n], [v], [adj])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  wordData.type ?? 'n/a', // Nếu chưa có trường này thì hiện n/a
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dòng 2: Phiên âm + Nghĩa
          Row(
            children: [
              Icon(
                Icons.volume_up_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                wordData.phonetic,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 12,
                color: theme.dividerColor,
              ), // Thanh dọc ngăn cách
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  wordData.translation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
