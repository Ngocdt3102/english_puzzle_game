import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgStart, AppColors.bgEnd],
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
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "HƯỚNG DẪN CHƠI",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Để cân bằng với nút back
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
                    ),
                    _buildStepCard(
                      icon: Icons.key_rounded,
                      title: "Bước 2: Tìm từ khóa",
                      desc:
                          "Mỗi từ phụ có một ô màu đặc biệt. Chữ cái ở ô đó sẽ tự động được điền lên hàng dọc để tạo thành Từ Khóa Chính.",
                    ),
                    _buildStepCard(
                      icon: Icons.lightbulb_outline_rounded,
                      title: "Bước 3: Dùng gợi ý",
                      desc:
                          "Nếu bí quá, hãy bấm vào Bóng Đèn. Nó sẽ điền hộ bạn một chữ cái đúng, nhưng bạn sẽ mất 1 lượt gợi ý đấy!",
                    ),
                    _buildStepCard(
                      icon: Icons.emoji_events_rounded,
                      title: "Bước 4: Chiến thắng",
                      desc:
                          "Khi Từ Khóa Chính được lấp đầy hoàn toàn, bạn sẽ vượt qua thử thách và nhận thêm điểm thưởng!",
                    ),
                    const SizedBox(height: 30),

                    // Nút bắt đầu ngay
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "ĐÃ HIỂU!",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
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
