import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart'; // --- THÊM SETTINGS PROVIDER ---

class MainWordView extends StatelessWidget {
  const MainWordView({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final mainWordDisplay = gameProvider.mainWordDisplay;

    // --- KÉO BỘ MÀU TỪ SETTINGS ---
    final themeIndex = context.watch<SettingsProvider>().themeIndex;
    final appColors = AppColors.getTheme(themeIndex);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Column(
        children: [
          Text(
            "TARGET",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: appColors.textMain.withOpacity(0.5), // Chữ tương phản mờ
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
                appColors, // Truyền bộ màu xuống hàm vẽ ô chữ
                key: gameProvider.getTargetKey(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Cập nhật hàm nhận thêm tham số appColors ---
  Widget _buildLetterBox(String letter, AppColors appColors, {Key? key}) {
    bool hasLetter = letter.isNotEmpty;

    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        // Ô trống sẽ dùng màu nền tối/sáng tùy Theme thay vì fix cứng màu trắng
        color: hasLetter
            ? appColors.secondary
            : appColors.defaultTile.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // Viền của ô trống sẽ mờ đi để không bị chói
          color: hasLetter
              ? appColors.secondary
              : appColors.textMain.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: hasLetter
            ? [
                BoxShadow(
                  color: appColors.secondary.withOpacity(
                    0.6,
                  ), // Bóng đổ theo màu phụ
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
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: appColors.textLight, // Màu chữ sáng nổi bật trên nền màu
        ),
      ),
    );
  }
}
