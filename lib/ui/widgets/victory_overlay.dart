import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/services/tts_service.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';

class VictoryOverlay extends StatefulWidget {
  const VictoryOverlay({super.key});

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay> {
  late ConfettiController _confettiController;

  // --- BIẾN ĐIỀU KHIỂN TRẠNG THÁI MỞ RỘNG CÂU DỊCH ---
  bool _isTranslationExpanded = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _confettiController.play();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final settings = context.read<SettingsProvider>();
      final provider = context.read<GameProvider>();
      final mainWord = provider.currentLevel?.mainWord.word ?? "";

      if (settings.isHapticEnabled) HapticFeedback.heavyImpact();
      if (settings.isSoundEnabled && mainWord.isNotEmpty)
        TTSService.speak(mainWord);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final mainWordData = provider.currentLevel?.mainWord;

    final mainWord = mainWordData?.word ?? "";
    final phonetic = mainWordData?.phonetic ?? "";
    final translation = mainWordData?.translation ?? "";
    final definitionEn = mainWordData?.definition ?? "";
    final definitionVi = mainWordData?.definitionVi ?? "";

    // --- LOGIC KIỂM TRA MÀN CUỐI CÙNG ---
    final currentLevels = provider.currentTopicLevels;
    final currentIndex = currentLevels.indexWhere(
      (l) => l.levelId == provider.currentLevelId,
    );
    final isLastLevel =
        currentIndex == currentLevels.length - 1; // True nếu là màn cuối

    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

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
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 30, // Tăng thêm tí pháo hoa cho vui mắt
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

        // 3. Giao diện bảng chúc mừng
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: appColors.defaultTile,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.primary.withOpacity(0.3),
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
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: appColors.secondary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "You found the target word:",
                      style: TextStyle(
                        fontSize: 14,
                        color: appColors.textMain.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Chữ khóa chính & Phiên âm
                    Text(
                      mainWord,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: appColors.primary,
                        letterSpacing: 3,
                      ),
                    ),
                    if (phonetic.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          phonetic,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: appColors.textMain.withOpacity(0.5),
                          ),
                        ),
                      ),

                    // Nghĩa tiếng Việt ngắn gọn
                    if (translation.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: appColors.selectedTile,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          translation,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: appColors.primary,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // --- BOX ĐỊNH NGHĨA CÓ HIỆU ỨNG MỞ RỘNG ---
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: appColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: appColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    definitionEn,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: appColors.textMain,
                                      fontStyle: FontStyle.italic,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                if (definitionVi.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      if (settings.isHapticEnabled)
                                        HapticFeedback.lightImpact();
                                      setState(() {
                                        _isTranslationExpanded =
                                            !_isTranslationExpanded;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isTranslationExpanded
                                            ? appColors.secondary
                                            : appColors.primary.withOpacity(
                                                0.15,
                                              ),
                                      ),
                                      child: Icon(
                                        _isTranslationExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.translate_rounded,
                                        size: 20,
                                        color: _isTranslationExpanded
                                            ? appColors.textLight
                                            : appColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (_isTranslationExpanded &&
                                definitionVi.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Divider(
                                  color: appColors.primary.withOpacity(0.2),
                                  height: 1,
                                ),
                              ),
                              Text(
                                definitionVi,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: appColors.textMain.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // --- NÚT ĐIỀU HƯỚNG THEO ĐIỀU KIỆN ---
                    if (isLastLevel)
                      // Nút bự khi hoàn thành toàn bộ chủ đề
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColors
                                .secondary, // Dùng màu rực rỡ hơn để ăn mừng
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: appColors.secondary.withOpacity(0.5),
                          ),
                          onPressed: () => Navigator.pop(
                            context,
                          ), // Thoát ra ngoài Level Selection
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "HOÀN THÀNH CHỦ ĐỀ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: appColors.textLight,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.amber,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // 2 Nút như bình thường nếu còn màn chơi
                      Row(
                        children: [
                          SizedBox(
                            height: 55,
                            width: 55,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: appColors.textMain,
                                side: BorderSide(
                                  color: appColors.textMain.withOpacity(0.2),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Icon(
                                Icons.grid_view_rounded,
                                color: appColors.textMain.withOpacity(0.6),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor: appColors.primary.withOpacity(
                                    0.5,
                                  ),
                                ),
                                onPressed: () => provider.loadNextLevel(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "NEXT LEVEL",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: appColors.textLight,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.double_arrow_rounded,
                                      color: appColors.textLight,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
