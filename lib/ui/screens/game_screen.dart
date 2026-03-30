import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart'; // THÊM IMPORT
import '../widgets/breathing_glow_widget.dart';
import '../widgets/clue_panel.dart';
import '../widgets/crossword_grid.dart';
import '../widgets/custom_keyboard.dart';
import '../widgets/flying_letter_widget.dart';
import '../widgets/main_word_view.dart';
import '../widgets/victory_overlay.dart';
import 'dictionary_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lắng nghe các Provider
    final gameProvider = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();

    // 2. Lấy bộ màu Theme hiện tại
    final appColors = AppColors.getTheme(settings.themeIndex);

    final isLevelCompleted = gameProvider.isLevelCompleted;
    final isKeyboardVisible = gameProvider.isKeyboardVisible;

    // --- BƯỚC PHÒNG THỦ: HIỆN LOADING KHI CHƯA CÓ DATA ---
    if (gameProvider.currentLevel == null) {
      return Scaffold(
        backgroundColor: appColors.bgStart,
        body: Center(
          child: CircularProgressIndicator(color: appColors.primary),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // --- LỚP DƯỚI: GIAO DIỆN GAME ---
          Container(
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
                  _buildHeader(
                    context,
                    appColors,
                  ), // Truyền appColors vào header
                  MainWordView(
                    key: ValueKey('main_${gameProvider.currentLevelId}'),
                  ),
                  CluePanel(
                    key: ValueKey('clue_${gameProvider.currentLevelId}'),
                  ),
                  CrosswordGrid(
                    key: ValueKey('grid_${gameProvider.currentLevelId}'),
                  ),

                  // Hiệu ứng ẩn hiện bàn phím mượt mà
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isKeyboardVisible
                        ? const CustomKeyboard()
                        : const SizedBox(width: double.infinity, height: 0),
                  ),
                ],
              ),
            ),
          ),

          // Hiệu ứng chữ bay
          if (gameProvider.currentFlyingData != null)
            FlyingLetterWidget(data: gameProvider.currentFlyingData!),

          // --- LỚP TRÊN: HIỆU ỨNG CHIẾN THẮNG ---
          if (isLevelCompleted) const VictoryOverlay(),
        ],
      ),
    );
  }

  // Header chứa Nút Thoát, Nút Từ Điển và Level ID
  Widget _buildHeader(BuildContext context, AppColors appColors) {
    final levelId = context.select((GameProvider p) => p.currentLevelId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // 1. NÚT THOÁT GAME (X)
              _buildHeaderButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.pop(context),
                appColors: appColors,
              ),
              const SizedBox(width: 10),
              // 2. NÚT MỞ TỪ ĐIỂN
              _buildHeaderButton(
                icon: Icons.menu_book_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DictionaryScreen()),
                  );
                },
                appColors: appColors,
              ),
            ],
          ),

          // HIỂN THỊ LEVEL ĐỘNG
          Text(
            "LEVEL $levelId",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: appColors.primary,
              letterSpacing: 1.5,
            ),
          ),

          // NÚT GỢI Ý (HINT) CÓ HIỆU ỨNG HÀO QUANG
          Consumer<GameProvider>(
            builder: (context, provider, child) {
              bool outOfHints = provider.hints <= 0;

              return BreathingGlowWidget(
                glowColor: appColors.secondary.withOpacity(0.5),
                isEnabled: !outOfHints,
                child: GestureDetector(
                  onTap: () => provider.useHint(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: outOfHints
                          ? Colors.grey.shade400
                          : appColors.secondary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${provider.hints}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget phụ trợ vẽ nút trên Header để tránh lặp code
  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    required AppColors appColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: appColors.defaultTile.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: appColors.primary),
      ),
    );
  }
}
