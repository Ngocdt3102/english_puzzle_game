import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Đã thêm thư viện này để tạo hiệu ứng Rung
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';

class CustomKeyboard extends StatelessWidget {
  const CustomKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final List<String> row1 = "QWERTYUIOP".split("");
    final List<String> row2 = "ASDFGHJKL".split("");
    final List<String> row3 = "ZXCVBNM".split("");

    double screenWidth = MediaQuery.of(context).size.width;
    double keyWidth = (screenWidth - 90) / 10;

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact(); // Rung khi đóng bàn phím
                  gameProvider.hideKeyboard();
                },
                child: const Icon(
                  Icons.keyboard_hide_rounded,
                  color: Colors.grey,
                  size: 28,
                ),
              ),
            ),
          ),
          _buildKeyboardRow(row1, gameProvider, keyWidth),
          const SizedBox(height: 10),
          _buildKeyboardRow(row2, gameProvider, keyWidth),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: keyWidth / 2),
              ...row3.map(
                (letter) => _KeyboardKey(
                  letter: letter,
                  keyWidth: keyWidth,
                  onTap: () => gameProvider.inputLetter(letter),
                ),
              ),
              _KeyboardKey(
                isBackspace: true,
                keyWidth: keyWidth * 1.5,
                onTap: () => gameProvider.deleteLetter(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(
    List<String> letters,
    GameProvider provider,
    double keyWidth,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters
          .map(
            (letter) => _KeyboardKey(
              letter: letter,
              keyWidth: keyWidth,
              onTap: () => provider.inputLetter(letter),
            ),
          )
          .toList(),
    );
  }
}

// --- WIDGET MỚI: XỬ LÝ HIỆU ỨNG NHẤN XUỐNG 3D ---
class _KeyboardKey extends StatefulWidget {
  final String? letter;
  final bool isBackspace;
  final double keyWidth;
  final VoidCallback onTap;

  const _KeyboardKey({
    this.letter,
    this.isBackspace = false,
    required this.keyWidth,
    required this.onTap,
  });

  @override
  State<_KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<_KeyboardKey> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 1. Lắng nghe Settings để lấy màu và cấu hình Rung
    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTapDown: (_) {
          // CHỈ RUNG KHI CÀI ĐẶT BẬT
          if (settings.isHapticEnabled) {
            HapticFeedback.lightImpact();
          }
          setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          width: widget.keyWidth,
          height: 50,
          margin: EdgeInsets.only(
            top: _isPressed ? 3.0 : 0.0,
            bottom: _isPressed ? 0.0 : 3.0,
          ),
          decoration: BoxDecoration(
            // DÙNG MÀU ĐỘNG TỪ appColors
            color: _isPressed
                ? appColors.primary.withOpacity(
                    0.7,
                  ) // Nhấn xuống thì đậm màu hơn
                : (widget.isBackspace
                      ? appColors.defaultTile.withOpacity(0.8)
                      : appColors.defaultTile),
            borderRadius: BorderRadius.circular(8),
            // Viền cũng dùng màu động để không bị chói ở nền tối
            border: Border.all(
              color: appColors.textMain.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: appColors.textMain.withOpacity(
                        0.2,
                      ), // Bóng đổ theo màu text để tự tương phản
                      blurRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: widget.isBackspace
              ? Icon(
                  Icons.backspace_rounded,
                  size: 22,
                  color: appColors.textMain, // ĐÃ SỬA LỖI: appColors.textMain
                )
              : Text(
                  widget.letter!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appColors.textMain, // ĐÃ SỬA LỖI
                  ),
                ),
        ),
      ),
    );
  }
}
