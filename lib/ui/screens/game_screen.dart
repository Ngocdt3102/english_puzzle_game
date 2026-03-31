import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';
import '../widgets/breathing_glow_widget.dart';
import '../widgets/clue_panel.dart';
import '../widgets/coin_rules_dialog.dart';
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
    final gameProvider = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    final isLevelCompleted = gameProvider.isLevelCompleted;
    final isKeyboardVisible = gameProvider.isKeyboardVisible;

    if (gameProvider.currentLevel == null) {
      return Scaffold(
        backgroundColor: appColors.bgStart,
        body: Center(
          child: CircularProgressIndicator(color: appColors.primary),
        ),
      );
    }

    return Scaffold(
      // Bật resizeToAvoidBottomInset để toàn bộ UI tự động đẩy lên khi bàn phím ảo của OS hiện lên (dù ta dùng bàn phím custom)
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [appColors.bgStart, appColors.bgEnd],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // --- HEADER: Tích hợp Coin và Hint ---
                  _buildHeader(context, appColors, gameProvider),

                  // --- KHU VỰC TỪ KHÓA CHÍNH (TARGET) ---
                  MainWordView(
                    key: ValueKey('main_${gameProvider.currentLevelId}'),
                  ),

                  // --- KHU VỰC GỢI Ý (CLUE) ---
                  CluePanel(
                    key: ValueKey('clue_${gameProvider.currentLevelId}'),
                  ),

                  // --- KHU VỰC LƯỚI TỪ PHỤ (CROSSWORD) ---
                  // Dùng Expanded để CrosswordGrid chiếm phần không gian còn lại
                  Expanded(
                    child: CrosswordGrid(
                      key: ValueKey('grid_${gameProvider.currentLevelId}'),
                    ),
                  ),

                  // --- BÀN PHÍM ẢO CUSTOM ---
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: isKeyboardVisible
                        ? const CustomKeyboard()
                        : const SizedBox(width: double.infinity, height: 0),
                  ),
                ],
              ),
            ),
          ),

          if (gameProvider.currentFlyingData != null)
            FlyingLetterWidget(data: gameProvider.currentFlyingData!),

          if (isLevelCompleted) const VictoryOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppColors appColors,
    GameProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút Đóng & Từ điển
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.pop(context),
                appColors: appColors,
              ),
              const SizedBox(width: 8),
              _buildHeaderButton(
                icon: Icons.menu_book_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DictionaryScreen()),
                ),
                appColors: appColors,
              ),
            ],
          ),

          // Số Level
          Text(
            "LEVEL ${provider.currentLevelId}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: appColors.primary,
              letterSpacing: 1.2,
            ),
          ),

          // Cụm Coin và Hint (Đặt sát nhau như thiết kế)
          Row(
            children: [
              _buildCoinButton(context, provider, appColors),
              const SizedBox(width: 6),
              _buildHintButton(provider, appColors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinButton(
    BuildContext context,
    GameProvider provider,
    AppColors appColors,
  ) {
    return GestureDetector(
      onTap: () => CoinRulesDialog.show(context, appColors),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              color: Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              "${provider.coins}",
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintButton(GameProvider provider, AppColors appColors) {
    return BreathingGlowWidget(
      glowColor: appColors.secondary.withOpacity(0.5),
      isEnabled: provider.hints > 0,
      child: GestureDetector(
        onTap: () => provider.useHint(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: provider.hints <= 0
                ? Colors.grey.shade400
                : appColors.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                "${provider.hints}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    required AppColors appColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: appColors.defaultTile.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: appColors.primary, size: 20),
      ),
    );
  }
}
