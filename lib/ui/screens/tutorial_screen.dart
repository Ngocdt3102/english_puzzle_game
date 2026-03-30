import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/settings_provider.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. LẤY BỘ MÀU THEME ĐỘNG
    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    return Scaffold(
      body: Container(
        width: double.infinity,
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
              // Header với nút quay lại
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: appColors.primary, // Thay AppColors -> appColors
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        "HƯỚNG DẪN CHƠI",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color:
                              appColors.primary, // Thay AppColors -> appColors
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Nội dung hướng dẫn
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  children: [
                    _buildStepCard(
                      icon: Icons.grid_on_rounded,
                      title: "Bước 1: Giải từ phụ",
                      desc:
                          "Nhập các chữ cái để hoàn thành các hàng ngang. Mỗi hàng ngang là một từ tiếng Anh có nghĩa.",
                      appColors: appColors, // Truyền bộ màu xuống
                    ),
                    _buildStepCard(
                      icon: Icons.key_rounded,
                      title: "Bước 2: Tìm từ khóa",
                      desc:
                          "Mỗi từ phụ có một ô màu đặc biệt. Chữ cái ở ô đó sẽ tự động được điền lên hàng dọc để tạo thành Từ Khóa Chính.",
                      appColors: appColors,
                    ),
                    _buildStepCard(
                      icon: Icons.lightbulb_outline_rounded,
                      title: "Bước 3: Dùng gợi ý",
                      desc:
                          "Nếu bí quá, hãy bấm vào Bóng Đèn. Nó sẽ điền hộ bạn một chữ cái đúng, nhưng bạn sẽ mất 1 lượt gợi ý đấy!",
                      appColors: appColors,
                    ),
                    _buildStepCard(
                      icon: Icons.emoji_events_rounded,
                      title: "Bước 4: Chiến thắng",
                      desc:
                          "Khi Từ Khóa Chính được lấp đầy hoàn toàn, bạn sẽ vượt qua thử thách và nhận thêm điểm thưởng!",
                      appColors: appColors,
                    ),
                    const SizedBox(height: 30),

                    // Nút bắt đầu ngay
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.primary, // Màu động
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 5,
                        shadowColor: appColors.primary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "ĐÃ HIỂU!",
                        style: TextStyle(
                          color: appColors.textLight, // Màu chữ sáng
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String desc,
    required AppColors appColors, // Thêm tham số nhận bộ màu
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Sử dụng defaultTile thay cho Colors.white để thích ứng Theme Tối
        color: appColors.defaultTile.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: appColors.textMain.withOpacity(0.1), // Viền mờ nhẹ
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: appColors.secondary, size: 30), // Màu phụ động
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
                    color: appColors.primary, // Màu chủ đạo động
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 14,
                    color: appColors.textMain.withOpacity(0.8), // Màu chữ động
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
