import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../widgets/home_animations.dart';
import 'dictionary_screen.dart';
import 'level_selection_screen.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin tiến độ từ Provider
    final gameProvider = context.watch<GameProvider>();
    final currentLevel = gameProvider.currentLevelId;
    final totalWords = gameProvider.unlockedWords.length;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgStart, AppColors.bgEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Nút Settings (Trang trí cho giống game thật)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Đẩy 2 nút về 2 đầu
                  children: [
                    // 1. NÚT HƯỚNG DẪN (Dấu chấm than - Bên trái)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TutorialScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.priority_high_rounded, // Dấu chấm than
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    // 2. NÚT RESET (Bên phải)
                    GestureDetector(
                      onTap: () => _showResetDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // --- LOGO / TÊN GAME ---
              _buildAppLogo(),

              const Spacer(flex: 1),

              // --- KHU VỰC THỐNG KÊ NHANH ---
              _buildStatsCard(totalWords),

              const SizedBox(height: 40),

              // --- NÚT PLAY KHỔNG LỒ ---
              _buildPlayButton(context, currentLevel),

              const SizedBox(height: 20),

              // --- NÚT MỞ TỪ ĐIỂN ---
              _buildDictionaryButton(context),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị Tên Game với hiệu ứng Text Shadow
  Widget _buildAppLogo() {
    // BỌC FLOATING WIDGET Ở NGOÀI CÙNG
    return FloatingWidget(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.extension_rounded,
              size: 80,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "VOCAB",
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 4,
              height: 1,
            ),
          ),
          const Text(
            "PUZZLE",
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.w900,
              color: AppColors.secondary,
              letterSpacing: 4,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị số từ đã học được
  Widget _buildStatsCard(int totalWords) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.military_tech_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            "Words Unlocked: $totalWords",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  // Nút Play 3D chuyển sang GameScreen
  Widget _buildPlayButton(BuildContext context, int currentLevel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // SỬA DÒNG NÀY: Chuyển sang màn hình chọn Level
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LevelSelectionScreen()),
            );
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.blue.shade700, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  // Đổi tên nút thành SELECT LEVEL
                  "SELECT LEVEL",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  // Hiển thị Level đang chơi dở
                  "Current: Level $currentLevel",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade100,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Nút phụ mở DictionaryScreen
  Widget _buildDictionaryButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DictionaryScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.secondary,
                  size: 24,
                ),
                SizedBox(width: 10),
                Text(
                  "MY DICTIONARY",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMain,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Reset Game?",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Tất cả tiến độ và từ vựng của bạn sẽ bị xóa. Bạn có chắc chắn không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Đóng dialog
            child: const Text(
              "Hủy",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              // Gọi hàm reset trong Provider
              context.read<GameProvider>().resetData();
              Navigator.pop(ctx); // Đóng dialog

              // Hiện thông báo nhỏ (SnackBar) dưới đáy màn hình
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Đã xóa dữ liệu thành công!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              "Xóa sạch",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
