import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import 'game_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final totalLevels = provider.totalLevels;
    final completedLevels = provider.completedLevels;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgStart, AppColors.bgEnd],
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
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "SELECT LEVEL",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Cân bằng UI
                  ],
                ),
              ),

              // --- GRID DANH SÁCH LEVEL ---
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 ô 1 hàng
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: totalLevels,
                  itemBuilder: (context, index) {
                    int levelId = index + 1;
                    // Logic mở khóa: Level 1 luôn mở. Level khác mở nếu Level trước đó đã hoàn thành.
                    bool isCompleted = completedLevels.contains(levelId);
                    bool isUnlocked =
                        levelId == 1 || completedLevels.contains(levelId - 1);

                    return _buildLevelBox(
                      context,
                      provider,
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

  // --- WIDGET Ô LEVEL ---
  Widget _buildLevelBox(
    BuildContext context,
    GameProvider provider,
    int levelId,
    bool isCompleted,
    bool isUnlocked,
  ) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          // Bấm vào thì load level đó và nhảy sang GameScreen
          provider.loadLevel(levelId);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GameScreen()),
          );
        } else {
          // Hiện thông báo nhẹ nếu chưa mở khóa
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Bạn cần hoàn thành Level ${levelId - 1} trước!"),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // Màu sắc: Đã qua -> Vàng cam (Secondary), Đang chơi -> Trắng, Khóa -> Xám mờ
          color: isCompleted
              ? AppColors.secondary
              : (isUnlocked ? Colors.white : Colors.white.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isUnlocked
                ? (isCompleted
                      ? AppColors.secondary
                      : AppColors.primary.withOpacity(0.5))
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(child: isLockedDisplay(levelId, isCompleted, isUnlocked)),
      ),
    );
  }

  // Hàm phụ trợ chọn nội dung hiển thị trong ô
  Widget isLockedDisplay(int levelId, bool isCompleted, bool isUnlocked) {
    if (!isUnlocked) {
      // TRẠNG THÁI KHÓA: Hình ổ khóa
      return Icon(Icons.lock_rounded, color: Colors.grey.shade400, size: 28);
    } else if (isCompleted) {
      // TRẠNG THÁI HOÀN THÀNH: Icon V tick
      return const Icon(
        Icons.check_circle_rounded,
        color: Colors.white,
        size: 32,
      );
    } else {
      // TRẠNG THÁI MỞ KHÓA (CHƯA CHƠI): Hiện số Level
      return Text(
        "$levelId",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      );
    }
  }
}
