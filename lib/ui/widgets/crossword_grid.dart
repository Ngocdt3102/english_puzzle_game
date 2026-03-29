import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import 'shake_widget.dart'; // THÊM DÒNG IMPORT NÀY

class CrosswordGrid extends StatelessWidget {
  const CrosswordGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    // 1. LẤY DỮ LIỆU AN TOÀN
    final subWords = gameProvider.currentLevel?.subWords ?? [];
    final solvedList = gameProvider.subWordSolved;
    final inputsList = gameProvider.subWordInputs;

    // 2. TẦNG PHÒNG THỦ
    if (subWords.isEmpty ||
        solvedList.length != subWords.length ||
        inputsList.length != subWords.length) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        itemCount: subWords.length,
        itemBuilder: (context, index) {
          // 3. TRUY XUẤT AN TOÀN
          bool isSelected = gameProvider.selectedSubWordIndex == index;
          bool isSolved = solvedList[index];
          String currentInput = inputsList[index];
          String targetWord = subWords[index].word;

          // THÊM MỚI: Lấy giá trị trigger từ Provider. Chỉ hàng nào đang bị lỗi mới nhận giá trị > 0
          int shakeTrigger = (gameProvider.errorSubWordIndex == index)
              ? gameProvider.wrongShakeTrigger
              : 0;

          // BỌC GESTURE DETECTOR TRONG SHAKE WIDGET
          return ShakeWidget(
            trigger: shakeTrigger,
            child: GestureDetector(
              onTap: () => gameProvider.selectSubWord(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Wrap(
                  spacing: 6,
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
    Key? key, // THÊM DÒNG NÀY: Nhận chìa khóa định vị tọa độ
    required String char,
    required bool isSelected,
    required bool isSolved,
    required bool isTargetChar,
  }) {
    // FIX: Sử dụng BoxShadow để tạo hiệu ứng 3D thay vì dùng Border không đồng nhất

    // Màu nền chính của ô chữ
    Color bgColor = isSolved
        ? AppColors.correctTile
        : (isSelected ? AppColors.selectedTile : AppColors.defaultTile);

    // Màu của viền ngoài
    Color borderColor = isTargetChar ? AppColors.primary : Colors.black12;

    // Màu của hiệu ứng đổ bóng 3D (đáy chữ)
    Color shadowColor = isTargetChar
        ? AppColors.primary
        : (isSolved ? Colors.green.shade800 : Colors.grey.shade400);

    return AnimatedContainer(
      key:
          key, // THÊM DÒNG NÀY: Gắn chìa khóa vào Container để làm điểm xuất phát
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 48,
      margin: const EdgeInsets.only(
        bottom: 4,
      ), // Tạo khoảng trống để hiện bóng đổ 3D
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isTargetChar ? 2 : 1),
        // HIỆU ỨNG 3D MỚI: Dùng bóng đổ cứng (blurRadius = 0) dịch xuống dưới (offset Y = 4)
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
          color: isSolved ? Colors.white : AppColors.textMain,
        ),
      ),
    );
  }
}
