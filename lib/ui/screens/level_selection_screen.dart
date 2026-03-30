import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Thêm để dùng Haptic
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart'; // Import Settings
import 'game_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final totalLevels = provider.totalLevels;
    final completedLevels = provider.completedLevels;

    // --- 1. LẤY BỘ MÀU THEME ĐỘNG ---
    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [appColors.bgStart, appColors.bgEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: appColors.primary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        "SELECT LEVEL",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: appColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // --- GRID DANH SÁCH LEVEL ---
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: totalLevels,
                  itemBuilder: (context, index) {
                    int levelId = index + 1;
                    bool isCompleted = completedLevels.contains(levelId);
                    bool isUnlocked =
                        levelId == 1 || completedLevels.contains(levelId - 1);

                    return _buildLevelBox(
                      context,
                      provider,
                      settings, // Truyền settings xuống
                      appColors, // Truyền màu xuống
                      levelId,
                      isCompleted,
                      isUnlocked,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBox(
    BuildContext context,
    GameProvider provider,
    SettingsProvider settings,
    AppColors appColors,
    int levelId,
    bool isCompleted,
    bool isUnlocked,
  ) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          // Rung nhẹ khi bấm nếu cài đặt cho phép
          if (settings.isHapticEnabled) HapticFeedback.lightImpact();

          provider.loadLevel(levelId);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GameScreen()),
          );
        } else {
          // Rung cảnh báo nếu bấm vào ô khóa
          if (settings.isHapticEnabled) HapticFeedback.vibrate();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: appColors.primary,
              content: Text(
                "Bạn cần hoàn thành Level ${levelId - 1} trước!",
                style: TextStyle(color: appColors.textLight),
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // Màu sắc ô linh hoạt theo Theme
          color: isCompleted
              ? appColors.correctTile
              : (isUnlocked
                    ? appColors.defaultTile
                    : appColors.textMain.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isUnlocked
                ? (isCompleted
                      ? appColors.correctTile
                      : appColors.primary.withOpacity(0.5))
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color:
                        (isCompleted
                                ? appColors.correctTile
                                : appColors.primary)
                            .withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: _buildIconOrText(levelId, isCompleted, isUnlocked, appColors),
        ),
      ),
    );
  }

  Widget _buildIconOrText(
    int levelId,
    bool isCompleted,
    bool isUnlocked,
    AppColors appColors,
  ) {
    if (!isUnlocked) {
      return Icon(
        Icons.lock_rounded,
        color: appColors.textMain.withOpacity(0.3),
        size: 24,
      );
    } else if (isCompleted) {
      return Icon(
        Icons.check_circle_rounded,
        color: appColors.textLight,
        size: 28,
      );
    } else {
      return Text(
        "$levelId",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: appColors.primary,
        ),
      );
    }
  }
}
