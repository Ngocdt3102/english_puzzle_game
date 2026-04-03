import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';
import '../widgets/home_animations.dart';
import '../widgets/settings_overlay.dart';
import 'dictionary_screen.dart';
import 'mile_stone_screen.dart'; // Import Milestone
import 'mode_selection_screen.dart';
import 'store_screen.dart'; // Import Store
import 'tutorial_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final totalWords = gameProvider.unlockedWords.length;
    final totalCompletedLevels = gameProvider.completedLevels.length;

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
              const SizedBox(height: 10),

              // --- HEADER: HƯỚNG DẪN, CÀI ĐẶT & CỬA HÀNG (COINS) ---
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
                        // NÚT STORE & HIỂN THỊ COINS (THIẾT KẾ MỚI)
                        _buildCoinStoreButton(
                          context,
                          gameProvider.coins,
                          appColors,
                        ),
                        const SizedBox(width: 12),
                        // NÚT CÀI ĐẶT
                        _buildHeaderCircleButton(
                          icon: Icons.settings_rounded,
                          onTap: () => SettingsOverlay.show(context),
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
              _buildStatsCard(totalWords, totalCompletedLevels, appColors),

              const SizedBox(height: 30),

              // --- NÚT CHÍNH: PLAY ---
              _buildStartButton(context, appColors),

              const SizedBox(height: 20),

              // --- HÀNG NÚT PHỤ: DICTIONARY & MILESTONE ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSecondaryButton(
                        context,
                        "DICTIONARY",
                        Icons.menu_book_rounded,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DictionaryScreen(),
                          ),
                        ),
                        appColors,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildSecondaryButton(
                        context,
                        "JOURNEY",
                        Icons.auto_graph_rounded,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MilestoneScreen(),
                          ),
                        ),
                        appColors,
                      ),
                    ),
                  ],
                ),
              ),

              // NÚT RESET NHỎ Ở DƯỚI CÙNG (TRÁNH BẤM NHẦM)
              TextButton(
                onPressed: () => _showResetDialog(context, appColors),
                child: Text(
                  "Reset Data",
                  style: TextStyle(
                    color: appColors.textMain.withOpacity(0.3),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // NÚT CỬA HÀNG VÀ COINS
  Widget _buildCoinStoreButton(
    BuildContext context,
    int coins,
    AppColors appColors,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StoreScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.amber.shade600, // Màu vàng đặc trưng của Coin
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              "$coins",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white70,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildStatsCard(int totalWords, int totalLevels, AppColors appColors) {
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
            Icons.emoji_events_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            "Unlocked: $totalWords Words | $totalLevels Levels",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: appColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // ĐIỂM THAY ĐỔI 1: Điều hướng sang ModeSelectionScreen
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
          ),
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
                // ĐIỂM THAY ĐỔI 2: Đổi chữ PLAY thành START
                Text(
                  "< START >",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: appColors.textLight,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 5),
                // ĐIỂM THAY ĐỔI 3: Đổi sub-title cho phù hợp với việc chọn Chế độ
                Text(
                  "Choose a mode to begin",
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

  // NÚT PHỤ (DÙNG CHO DICTIONARY VÀ MILESTONE)
  Widget _buildSecondaryButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
    AppColors appColors,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: appColors.defaultTile,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: appColors.textMain.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: appColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: appColors.textMain,
                  letterSpacing: 1,
                ),
              ),
            ],
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
          "Tất cả tiến độ, vàng và từ vựng của bạn sẽ bị xóa. Bạn có chắc không?",
          style: TextStyle(color: appColors.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<GameProvider>().resetData();
              Navigator.pop(ctx);
            },
            child: const Text(
              "Xóa sạch",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
