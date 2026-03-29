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

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 20),
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
              padding: const EdgeInsets.only(right: 15, bottom: 5),
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
          _buildKeyboardRow(row1, gameProvider),
          const SizedBox(height: 10),
          _buildKeyboardRow(row2, gameProvider),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 45), // Cân bằng không gian
              ...row3.map((letter) => _buildKey(letter, gameProvider)),
              _buildBackspaceKey(gameProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> letters, GameProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters.map((letter) => _buildKey(letter, provider)).toList(),
    );
  }

  Widget _buildKey(String letter, GameProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => provider.inputLetter(letter),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 34,
            height: 50,
            margin: const EdgeInsets.only(
              bottom: 3,
            ), // Cấp khoảng trống cho bóng 3D
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              // FIX: Dùng Border.all thay vì Border(bottom)
              border: Border.all(color: Colors.grey.shade300, width: 1),
              // Tạo viền đáy 3D bằng BoxShadow
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

  Widget _buildBackspaceKey(GameProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => provider.deleteLetter(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 50,
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
