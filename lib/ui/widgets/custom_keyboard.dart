import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';

class CustomKeyboard extends StatelessWidget {
  const CustomKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final List<String> row1 = "QWERTYUIOP".split("");
    final List<String> row2 = "ASDFGHJKL".split("");
    final List<String> row3 = "ZXCVBNM".split("");

    // --- TÍNH TOÁN KÍCH THƯỚC ĐỘNG (ĐÃ CẬP NHẬT) ---
    double screenWidth = MediaQuery.of(context).size.width;
    // Padding 2 bên ngoài cùng là 30 (15 trái, 15 phải)
    // Margin giữa 10 phím là 60 (Mỗi phím 3 trái, 3 phải)
    // Tổng không gian bị chiếm: 30 + 60 = 90
    double keyWidth = (screenWidth - 90) / 10;

    return Container(
      // CẬP NHẬT PADDING TẠI ĐÂY: Thụt lề trái phải 15px, lề dưới 25px để cách xa mép dưới màn hình
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 5,
                bottom: 5,
              ), // Chỉnh lại một chút cho cân với nút ẩn
              child: GestureDetector(
                onTap: () => gameProvider.hideKeyboard(),
                child: const Icon(
                  Icons.keyboard_hide_rounded,
                  color: Colors.grey,
                  size: 28,
                ),
              ),
            ),
          ),
          _buildKeyboardRow(row1, gameProvider, keyWidth),
          const SizedBox(height: 10),
          _buildKeyboardRow(row2, gameProvider, keyWidth),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: keyWidth / 2),
              ...row3.map(
                (letter) => _buildKey(letter, gameProvider, keyWidth),
              ),
              _buildBackspaceKey(gameProvider, keyWidth * 1.5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(
    List<String> letters,
    GameProvider provider,
    double keyWidth,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters
          .map((letter) => _buildKey(letter, provider, keyWidth))
          .toList(),
    );
  }

  Widget _buildKey(String letter, GameProvider provider, double keyWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => provider.inputLetter(letter),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: keyWidth,
            height: 50,
            margin: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey(GameProvider provider, double keyWidth) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => provider.deleteLetter(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: keyWidth,
            height: 50,
            margin: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.backspace_rounded,
              size: 22,
              color: AppColors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}
