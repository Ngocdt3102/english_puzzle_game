import 'dart:math';
import 'dart:ui'; // BẮT BUỘC IMPORT dart:ui ĐỂ DÙNG LERP

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';

class FlyingLetterWidget extends StatelessWidget {
  final FlyingData data;

  const FlyingLetterWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final themeIndex = context.watch<SettingsProvider>().themeIndex;
    final appColors = AppColors.getTheme(themeIndex);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        // 1. Tính toán X, Y trên đường bay
        double currentX = data.start.dx + (data.end.dx - data.start.dx) * value;
        double currentY = data.start.dy + (data.end.dy - data.start.dy) * value;

        // 2. Toán học: Hàm Sin tạo độ nảy (Arc) cao 80 pixel lên trời
        double arc = sin(value * pi) * -80;

        // 3. NỘI SUY KÍCH THƯỚC: Biến đổi từ Size nhỏ sang Size to
        double currentWidth =
            lerpDouble(data.startSize.width, data.endSize.width, value) ??
            data.startSize.width;
        double currentHeight =
            lerpDouble(data.startSize.height, data.endSize.height, value) ??
            data.startSize.height;

        // 4. NỘI SUY CỠ CHỮ: Chuyển từ size 22 sang size 28
        double currentFontSize = lerpDouble(22.0, 28.0, value) ?? 22.0;

        // 5. NỘI SUY BO GÓC: Chuyển từ bo 8px sang bo 12px
        double currentRadius = lerpDouble(8.0, 12.0, value) ?? 8.0;

        return Positioned(
          left: currentX,
          top: currentY + arc,
          child: Transform.scale(
            // Vẫn giữ hiệu ứng phóng to nảy lên 30% giữa không trung để tạo cảm giác 3D
            scale: 1.0 + sin(value * pi) * 0.3,
            child: Container(
              width: currentWidth, // Dùng width đã tính toán
              height: currentHeight, // Dùng height đã tính toán
              decoration: BoxDecoration(
                color: appColors.primary,
                borderRadius: BorderRadius.circular(currentRadius),
                boxShadow: [
                  BoxShadow(
                    color: appColors.primary.withOpacity(0.8),
                    blurRadius:
                        15 *
                        sin(
                          value * pi,
                        ), // Chỉ lóe sáng mạnh lúc đang bay giữa trời
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                data.letter,
                style: TextStyle(
                  fontSize: currentFontSize, // Dùng cỡ chữ đã tính toán
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
