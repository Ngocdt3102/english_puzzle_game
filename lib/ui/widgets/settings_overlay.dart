import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/settings_provider.dart';

class SettingsOverlay {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // Cho phép BottomSheet có thể kéo cao hơn nếu cần
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final appColors = AppColors.getTheme(settings.themeIndex);

            return Container(
              // padding đáy nên linh hoạt hơn
              padding: const EdgeInsets.only(
                top: 15,
                left: 25,
                right: 25,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: appColors.defaultTile,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Quan trọng: Co giãn theo nội dung
                children: [
                  // Thanh Drag nhỏ
                  Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: appColors.textMain.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tiêu đề
                  Text(
                    "SETTINGS",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: appColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- GIẢI PHÁP SỬA LỖI OVERFLOW: Bọc nội dung vào ScrollView ---
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Nút Tắt/Mở Giọng đọc
                          _buildSwitchTile(
                            icon: Icons.volume_up_rounded,
                            title: "Voice Pronunciation",
                            subtitle: "Read words aloud automatically",
                            value: settings.isSoundEnabled,
                            appColors: appColors,
                            onChanged: (val) {
                              if (settings.isHapticEnabled) {
                                HapticFeedback.lightImpact();
                              }
                              settings.toggleSound(val);
                            },
                          ),
                          Divider(
                            height: 25,
                            color: appColors.textMain.withOpacity(0.1),
                          ),

                          // Nút Tắt/Mở Rung
                          _buildSwitchTile(
                            icon: Icons.vibration_rounded,
                            title: "Haptic Feedback",
                            subtitle: "Vibrate on key press",
                            value: settings.isHapticEnabled,
                            appColors: appColors,
                            onChanged: (val) {
                              if (val) HapticFeedback.lightImpact();
                              settings.toggleHaptic(val);
                            },
                          ),
                          Divider(
                            height: 25,
                            color: appColors.textMain.withOpacity(0.1),
                          ),

                          // Phần chọn Theme
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "APP THEME",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: appColors.textMain.withOpacity(0.6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildThemeOption(
                                context,
                                settings,
                                0,
                                "Classic",
                                Colors.blue,
                                appColors,
                              ),
                              _buildThemeOption(
                                context,
                                settings,
                                1,
                                "Minimal",
                                Colors.orange,
                                appColors,
                              ),
                              _buildThemeOption(
                                context,
                                settings,
                                2,
                                "Cyber",
                                Colors.teal,
                                appColors,
                              ),
                            ],
                          ),
                          // Thêm khoảng đệm cuối để không bị sát mép màn hình khi cuộn
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ... (Giữ nguyên các hàm _buildSwitchTile và _buildThemeOption của bạn)
  static Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required AppColors appColors,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: appColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: appColors.primary, size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appColors.textMain,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: appColors.textMain.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: appColors.primary,
          activeTrackColor: appColors.primary.withOpacity(0.3),
        ),
      ],
    );
  }

  static Widget _buildThemeOption(
    BuildContext context,
    SettingsProvider settings,
    int index,
    String label,
    Color color,
    AppColors appColors,
  ) {
    bool isSelected = settings.themeIndex == index;
    return GestureDetector(
      onTap: () {
        if (settings.isHapticEnabled) HapticFeedback.selectionClick();
        settings.changeTheme(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ), // Giảm nhẹ padding ngang
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : appColors.textMain.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? color : appColors.textMain.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
