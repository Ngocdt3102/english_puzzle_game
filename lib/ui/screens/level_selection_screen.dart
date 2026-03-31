import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';
import 'game_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    // --- LẤY DANH SÁCH LEVEL THỰC TẾ TỪ JSON VÀ ID CHỦ ĐỀ HIỆN TẠI ---
    final currentLevels = provider.currentTopicLevels;
    final totalLevels = currentLevels.length;
    final completedLevels = provider.completedLevels;
    final currentTopicId = provider.currentTopicId;

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
                    // 1. Lấy ID thật sự ghi trong file JSON
                    int actualLevelId = currentLevels[index].levelId;

                    // 2. Kiểm tra hoàn thành bằng Khóa kết hợp (Ví dụ: FOOD_01_1)
                    bool isCompleted = completedLevels.contains(
                      "${currentTopicId}_$actualLevelId",
                    );

                    // 3. Logic mở khóa: Ô đầu tiên luôn mở. Ô sau mở nếu ô trước nó (trong file JSON) đã hoàn thành.
                    bool isUnlocked =
                        index == 0 ||
                        completedLevels.contains(
                          "${currentTopicId}_${currentLevels[index - 1].levelId}",
                        );

                    return _buildLevelBox(
                      context,
                      provider,
                      settings,
                      appColors,
                      actualLevelId, // Truyền ID thực tế xuống để load game
                      isCompleted,
                      isUnlocked,
                      index +
                          1, // Truyền số thứ tự (1, 2, 3...) để hiển thị giao diện
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
    int actualLevelId,
    bool isCompleted,
    bool isUnlocked,
    int displayIndex, // Số thứ tự hiển thị ra màn hình
  ) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          // Rung nhẹ khi bấm nếu cài đặt cho phép
          if (settings.isHapticEnabled) HapticFeedback.lightImpact();

          // Nạp dữ liệu bằng ID thật của level
          provider.loadLevel(actualLevelId);
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
                "Bạn cần hoàn thành Level ${displayIndex - 1} trước!",
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
          child: _buildIconOrText(
            displayIndex,
            isCompleted,
            isUnlocked,
            appColors,
          ),
        ),
      ),
    );
  }

  Widget _buildIconOrText(
    int displayIndex,
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
        "$displayIndex",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: appColors.primary,
        ),
      );
    }
  }
}
