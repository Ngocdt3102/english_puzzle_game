import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để dùng HapticFeedback
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/services/tts_service.dart'; // Để dùng Giọng đọc
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart'; // --- THÊM SETTINGS PROVIDER ---

class VictoryOverlay extends StatefulWidget {
  const VictoryOverlay({super.key});

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _confettiController.play(); // Bắn pháo hoa ngay khi mở

    // --- THÊM ĐOẠN NÀY ĐỂ KÍCH HOẠT ÂM THANH & RUNG ---
    // Dùng addPostFrameCallback để đợi giao diện vẽ xong mới đọc/rung
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final settings = context.read<SettingsProvider>();
      final provider = context.read<GameProvider>();
      final mainWord = provider.currentLevel?.mainWord.word ?? "";

      // 1. Nếu bật Rung -> Rung MẠNH để ăn mừng chiến thắng
      if (settings.isHapticEnabled) {
        HapticFeedback.heavyImpact();
      }

      // 2. Nếu bật Tự động phát âm -> Đọc to Từ khóa chính
      if (settings.isSoundEnabled && mainWord.isNotEmpty) {
        TTSService.speak(mainWord);
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameProvider>();
    final mainWord = provider.currentLevel?.mainWord.word ?? "";
    final definition = provider.currentLevel?.mainWord.definition ?? "";
    final translation = provider.currentLevel?.mainWord.translation ?? "";

    // --- 1. KÉO BỘ MÀU TỪ SETTINGS ---
    final themeIndex = context.watch<SettingsProvider>().themeIndex;
    final appColors = AppColors.getTheme(themeIndex);

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Phủ nền đen mờ
        Container(color: Colors.black.withOpacity(0.7)),

        // 2. Máy bắn pháo hoa
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // Bắn xuống
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),

        // 3. Giao diện bảng chúc mừng + Hiệu ứng nảy
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: appColors
                      .defaultTile, // Tự động đổi màu trắng/tối theo theme
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.primary.withOpacity(
                        0.3,
                      ), // Đổi màu bóng đổ thành màu chủ đạo
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "AWESOME!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: appColors.secondary, // Màu động
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "You found the target word:",
                      style: TextStyle(
                        fontSize: 14,
                        color: appColors.textMain.withOpacity(
                          0.7,
                        ), // Tương phản mờ
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Chữ khóa chính
                    Text(
                      mainWord,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: appColors.primary, // Màu động
                        letterSpacing: 4,
                      ),
                    ),

                    // --- NGHĨA TIẾNG VIỆT ---
                    if (translation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: appColors.selectedTile, // Nền làm nổi khối
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          translation,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: appColors.primary, // Màu động
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 15),

                    // Hiển thị định nghĩa (Tiếng Anh)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: appColors.primary.withOpacity(
                          0.08,
                        ), // Màu nền tinh tế
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: appColors.primary.withOpacity(
                            0.2,
                          ), // Viền mỏng mờ
                        ),
                      ),
                      child: Text(
                        definition,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: appColors.textMain, // Màu động
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Nút Next Level
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColors.primary, // Màu động
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: appColors.primary.withOpacity(0.5),
                        ),
                        onPressed: () => provider.loadNextLevel(),
                        child: Text(
                          "NEXT LEVEL",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: appColors.textLight, // Chữ sáng
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
