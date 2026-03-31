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

    final subWords = gameProvider.currentLevel?.subWords ?? [];
    final solvedList = gameProvider.subWordSolved;
    final inputsList = gameProvider.subWordInputs;

    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    if (subWords.isEmpty ||
        solvedList.length != subWords.length ||
        inputsList.length != subWords.length) {
      return Center(child: CircularProgressIndicator(color: appColors.primary));
    }

    // Không còn shrinkWrap: true và NeverScrollable nữa. Trả lại khả năng cuộn tự nhiên.
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
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
                    appColors: appColors,
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharBox({
    Key? key,
    required String char,
    required bool isSelected,
    required bool isSolved,
    required bool isTargetChar,
    required AppColors appColors,
  }) {
    Color bgColor = isSolved
        ? appColors.correctTile
        : (isSelected ? appColors.selectedTile : appColors.defaultTile);

    Color borderColor = isTargetChar
        ? appColors.primary
        : appColors.textMain.withOpacity(0.1);

    Color shadowColor = isTargetChar
        ? appColors.primary.withOpacity(0.8)
        : (isSolved
              ? appColors.correctTile.withOpacity(0.6)
              : appColors.textMain.withOpacity(0.2));

    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 300),
      width: 36, // Trả lại kích thước vừa phải
      height: 44,
      margin: const EdgeInsets.only(bottom: 2),
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isSolved ? Colors.white : appColors.textMain,
        ),
      ),
    );
  }
}
