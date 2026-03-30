import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';

class CluePanel extends StatelessWidget {
  const CluePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final currentLevel = gameProvider.currentLevel;

    if (currentLevel == null) return const SizedBox.shrink();

    final selectedIndex = gameProvider.selectedSubWordIndex;
    final subWord = currentLevel.subWords[selectedIndex];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "CLUE ${selectedIndex + 1}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- Gợi ý Tiếng Anh ---
          Text(
            subWord.clue,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
              height: 1.3,
            ),
          ),

          // --- PHẦN MỚI THÊM: Dịch nghĩa Tiếng Việt ---
          if (subWord.details.translation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(
                  0.08,
                ), // Nền xanh rất nhạt, thanh lịch
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Dịch: ${subWord.details.translation}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700, // Chữ xanh nổi bật
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
