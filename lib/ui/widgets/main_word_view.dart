import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';

class MainWordView extends StatelessWidget {
  const MainWordView({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final mainWordDisplay = gameProvider.mainWordDisplay;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Column(
        children: [
          const Text(
            "TARGET",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.black45,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(
              mainWordDisplay.length,
              (index) => _buildLetterBox(
                mainWordDisplay[index],
                // THÊM DÒNG NÀY: Truyền chìa khóa đích (bãi đáp) vào từng ô vuông
                key: gameProvider.getTargetKey(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // THÊM DÒNG NÀY: Cập nhật hàm nhận thêm tham số Key
  Widget _buildLetterBox(String letter, {Key? key}) {
    bool hasLetter = letter.isNotEmpty;

    return AnimatedContainer(
      key: key, // THÊM DÒNG NÀY: Gắn chìa khóa vào Container để lưu tọa độ
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut, // Hiệu ứng nảy lên
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: hasLetter ? AppColors.secondary : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasLetter ? AppColors.secondary : Colors.white,
          width: 2,
        ),
        boxShadow: hasLetter
            ? [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
