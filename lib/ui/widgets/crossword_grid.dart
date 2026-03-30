import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';
import 'shake_widget.dart';

class CrosswordGrid extends StatelessWidget {
  const CrosswordGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    // 1. LẤY DỮ LIỆU AN TOÀN
    final subWords = gameProvider.currentLevel?.subWords ?? [];
    final solvedList = gameProvider.subWordSolved;
    final inputsList = gameProvider.subWordInputs;

    // --- LẤY BỘ MÀU THEME HIỆN TẠI ---
    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    // 2. TẦNG PHÒNG THỦ
    if (subWords.isEmpty ||
        solvedList.length != subWords.length ||
        inputsList.length != subWords.length) {
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(color: appColors.primary),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        itemCount: subWords.length,
        itemBuilder: (context, index) {
          bool isSelected = gameProvider.selectedSubWordIndex == index;
          bool isSolved = solvedList[index];
          String currentInput = inputsList[index];
          String targetWord = subWords[index].word;

          int shakeTrigger = (gameProvider.errorSubWordIndex == index)
              ? gameProvider.wrongShakeTrigger
              : 0;

          return ShakeWidget(
            trigger: shakeTrigger,
            child: GestureDetector(
              onTap: () => gameProvider.selectSubWord(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // Nền hàng: Dùng màu tile mặc định để thích ứng Dark/Light
                  color: isSelected
                      ? appColors.defaultTile
                      : appColors.defaultTile.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected
                        ? appColors.primary.withOpacity(0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: appColors.primary.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(targetWord.length, (charIndex) {
                    String char = charIndex < currentInput.length
                        ? currentInput[charIndex]
                        : "";
                    return _buildCharBox(
                      key: charIndex == subWords[index].extractIndex
                          ? gameProvider.getSourceKey(index, charIndex)
                          : null,
                      char: char,
                      isSelected: isSelected,
                      isSolved: isSolved,
                      isTargetChar: charIndex == subWords[index].extractIndex,
                      appColors: appColors, // Truyền màu xuống
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCharBox({
    Key? key,
    required String char,
    required bool isSelected,
    required bool isSolved,
    required bool isTargetChar,
    required AppColors appColors, // Nhận bộ màu
  }) {
    // Màu nền ô chữ
    Color bgColor = isSolved
        ? appColors.correctTile
        : (isSelected ? appColors.selectedTile : appColors.defaultTile);

    // Màu viền (Nổi bật ô trích xuất chữ)
    Color borderColor = isTargetChar
        ? appColors.primary
        : appColors.textMain.withOpacity(0.1);

    // Màu bóng đổ 3D (Đáy chữ)
    Color shadowColor = isTargetChar
        ? appColors.primary.withOpacity(0.8)
        : (isSolved
              ? appColors.correctTile.withOpacity(0.6)
              : appColors.textMain.withOpacity(0.2));

    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 48,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isTargetChar ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isSolved ? Colors.white : appColors.textMain,
        ),
      ),
    );
  }
}
