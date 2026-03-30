import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart'; // THÊM SETTINGS PROVIDER
import '../widgets/home_animations.dart';
import '../widgets/settings_overlay.dart'; // THÊM SETTINGS OVERLAY
import 'dictionary_screen.dart';
import 'level_selection_screen.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. LẤY THÔNG TIN TIẾN ĐỘ VÀ BỘ MÀU THEME
    final gameProvider = context.watch<GameProvider>();
    final currentLevel = gameProvider.currentLevelId;
    final totalWords = gameProvider.unlockedWords.length;

    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [appColors.bgStart, appColors.bgEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- HEADER: HƯỚNG DẪN & CÀI ĐẶT & RESET ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // NÚT HƯỚNG DẪN
                    _buildHeaderCircleButton(
                      icon: Icons.priority_high_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TutorialScreen(),
                        ),
                      ),
                      appColors: appColors,
                    ),

                    Row(
                      children: [
                        // NÚT CÀI ĐẶT (MỚI THÊM)
                        _buildHeaderCircleButton(
                          icon: Icons.settings_rounded,
                          onTap: () => SettingsOverlay.show(context),
                          appColors: appColors,
                        ),
                        const SizedBox(width: 15),
                        // NÚT RESET
                        _buildHeaderCircleButton(
                          icon: Icons.refresh_rounded,
                          onTap: () => _showResetDialog(context, appColors),
                          appColors: appColors,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // --- LOGO / TÊN GAME ---
              _buildAppLogo(appColors),

              const Spacer(flex: 1),

              // --- KHU VỰC THỐNG KÊ NHANH ---
              _buildStatsCard(totalWords, appColors),

              const SizedBox(height: 40),

              // --- NÚT PLAY / SELECT LEVEL ---
              _buildPlayButton(context, currentLevel, appColors),

              const SizedBox(height: 20),

              // --- NÚT MỞ TỪ ĐIỂN ---
              _buildDictionaryButton(context, appColors),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm phụ vẽ các nút tròn nhỏ trên Header
  Widget _buildHeaderCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required AppColors appColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: appColors.defaultTile.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: appColors.primary),
      ),
    );
  }

  Widget _buildAppLogo(AppColors appColors) {
    return FloatingWidget(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: appColors.defaultTile,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: appColors.primary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.extension_rounded,
              size: 80,
              color: appColors.secondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "VOCAB",
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.w900,
              color: appColors.primary,
              letterSpacing: 4,
              height: 1,
            ),
          ),
          Text(
            "PUZZLE",
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.w900,
              color: appColors.secondary,
              letterSpacing: 4,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int totalWords, AppColors appColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: appColors.defaultTile.withOpacity(0.6),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: appColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(
    BuildContext context,
    int currentLevel,
    AppColors appColors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
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
              color: appColors.primary,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: appColors.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "SELECT LEVEL",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: appColors.textLight,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Current: Level $currentLevel",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appColors.textLight.withOpacity(0.8),
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

  Widget _buildDictionaryButton(BuildContext context, AppColors appColors) {
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
              color: appColors.defaultTile,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: appColors.textMain.withOpacity(0.1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: appColors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  "MY DICTIONARY",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: appColors.textMain,
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

  void _showResetDialog(BuildContext context, AppColors appColors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appColors.defaultTile,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Reset Game?",
          style: TextStyle(
            color: appColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Tất cả tiến độ và từ vựng của bạn sẽ bị xóa. Bạn có chắc chắn không?",
          style: TextStyle(color: appColors.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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
              context.read<GameProvider>().resetData();
              Navigator.pop(ctx);
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
