import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';

class CluePanel extends StatefulWidget {
  const CluePanel({super.key});

  @override
  State<CluePanel> createState() => _CluePanelState();
}

class _CluePanelState extends State<CluePanel> {
  bool _isShowingVietnamese = false;
  Timer? _hideTimer;
  int _lastSelectedIndex = -1;

  void _showVietnameseClue(SettingsProvider settings) {
    if (settings.isHapticEnabled) HapticFeedback.lightImpact();

    setState(() {
      _isShowingVietnamese = true;
    });

    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isShowingVietnamese = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final currentLevel = gameProvider.currentLevel;

    if (currentLevel == null) return const SizedBox.shrink();

    final selectedIndex = gameProvider.selectedSubWordIndex;

    if (selectedIndex != _lastSelectedIndex) {
      _isShowingVietnamese = false;
      _hideTimer?.cancel();
      _lastSelectedIndex = selectedIndex;
    }

    final subWord = currentLevel.subWords[selectedIndex];
    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    final clueVi = subWord.details.fullDefinitionVi;
    final hasVietnamese = clueVi.isNotEmpty;

    return Container(
      width: double.infinity,
      // ÉP KÍCH THƯỚC: margin dọc = 5, padding dọc = 12
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: appColors.defaultTile,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // NÚT TRANSLATE ĐƯỢC KÉO LÊN CÙNG HÀNG VỚI TIÊU ĐỀ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: appColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "CLUE ${selectedIndex + 1}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: appColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              if (hasVietnamese)
                GestureDetector(
                  onTap: _isShowingVietnamese
                      ? null
                      : () => _showVietnameseClue(settings),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isShowingVietnamese
                          ? appColors.textMain.withOpacity(0.05)
                          : appColors.primary.withOpacity(0.15),
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      color: _isShowingVietnamese
                          ? appColors.textMain.withOpacity(0.2)
                          : appColors.primary,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isShowingVietnamese && hasVietnamese ? clueVi : subWord.clue,
              key: ValueKey<bool>(_isShowingVietnamese),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15, // Rút gọn size chữ
                fontWeight: FontWeight.w600,
                color: _isShowingVietnamese && hasVietnamese
                    ? appColors.secondary
                    : appColors.textMain,
                height: 1.3,
                fontStyle: _isShowingVietnamese
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
