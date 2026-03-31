import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';

class MainWordView extends StatelessWidget {
  const MainWordView({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final mainWordDisplay = gameProvider.mainWordDisplay;

    final themeIndex = context.watch<SettingsProvider>().themeIndex;
    final appColors = AppColors.getTheme(themeIndex);

    return Container(
      width: double.infinity, // Bắt buộc để canh trái mượt mà
      // Margin đã được thu nhỏ tối đa để nhường chỗ
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // CANH TRÁI THEO Ô ĐỎ
        children: [
          Text(
            "TARGET",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: appColors.textMain.withOpacity(0.5),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 8,
            alignment: WrapAlignment.start, // CANH TRÁI CÁC Ô CHỮ
            children: List.generate(
              mainWordDisplay.length,
              (index) => _buildLetterBox(
                mainWordDisplay[index],
                appColors,
                key: gameProvider.getTargetKey(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterBox(String letter, AppColors appColors, {Key? key}) {
    bool hasLetter = letter.isNotEmpty;

    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      width: 38, // Kích thước gọn nhẹ
      height: 46,
      decoration: BoxDecoration(
        color: hasLetter
            ? appColors.secondary
            : appColors.defaultTile.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasLetter
              ? appColors.secondary
              : appColors.textMain.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: hasLetter
            ? [
                BoxShadow(
                  color: appColors.secondary.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: appColors.textLight,
        ),
      ),
    );
  }
}
