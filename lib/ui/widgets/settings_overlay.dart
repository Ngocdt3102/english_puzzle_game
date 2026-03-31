import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart'; // Thêm để gọi resetData
import '../../logic/settings_provider.dart';

class SettingsOverlay {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final appColors = AppColors.getTheme(settings.themeIndex);

            return Container(
              padding: const EdgeInsets.only(
                top: 15,
                left: 25,
                right: 25,
                bottom: 30, // Tăng nhẹ bottom padding cho nút Reset
              ),
              decoration: BoxDecoration(
                color: appColors.defaultTile,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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

                          const SizedBox(height: 30),
                          Divider(color: appColors.textMain.withOpacity(0.1)),
                          const SizedBox(height: 10),

                          // --- NÚT RESET DATA MỚI ---
                          _buildResetButton(context, appColors, settings),

                          const SizedBox(height: 10),
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

  // --- WIDGET NÚT RESET ---
  static Widget _buildResetButton(
    BuildContext context,
    AppColors appColors,
    SettingsProvider settings,
  ) {
    return InkWell(
      onTap: () {
        if (settings.isHapticEnabled) HapticFeedback.mediumImpact();
        // Gọi lại logic Reset Dialog mà bạn đã có ở HomeScreen
        _showResetConfirmation(context, appColors);
      },
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.redAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reset Game Progress",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  Text(
                    "Delete all coins, words, and levels",
                    style: TextStyle(
                      fontSize: 12,
                      color: appColors.textMain.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: appColors.textMain.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  // --- HỘP THOẠI XÁC NHẬN RESET ---
  static void _showResetConfirmation(
    BuildContext context,
    AppColors appColors,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appColors.defaultTile,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Reset Game?",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Tất cả tiến độ, vàng và từ vựng của bạn sẽ bị xóa vĩnh viễn. Bạn có chắc không?",
          style: TextStyle(color: appColors.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              // Gọi hàm reset từ GameProvider
              context.read<GameProvider>().resetData();
              Navigator.pop(ctx); // Đóng Dialog
              Navigator.pop(context); // Đóng luôn Settings BottomSheet

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Dữ liệu đã được xóa sạch!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              "Xác nhận xóa",
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

  // --- CÁC WIDGET PHỤ TRỢ (GIỮ NGUYÊN) ---
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
