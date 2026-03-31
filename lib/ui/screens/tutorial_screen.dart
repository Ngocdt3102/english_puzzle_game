import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/settings_provider.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    return DefaultTabController(
      length: 3, // 3 Tab nội dung
      child: Scaffold(
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
                // --- CUSTOM HEADER ---
                _buildHeader(context, appColors),

                // --- TAB BAR NAVIGATION ---
                TabBar(
                  indicatorColor: appColors.secondary,
                  labelColor: appColors.primary,
                  unselectedLabelColor: appColors.textMain.withOpacity(0.5),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(
                      text: "CÁCH CHƠI",
                      icon: Icon(Icons.videogame_asset_rounded),
                    ),
                    Tab(
                      text: "VÀNG & THƯỞNG",
                      icon: Icon(Icons.monetization_on_rounded),
                    ),
                    Tab(
                      text: "MẸO & CỬA HÀNG",
                      icon: Icon(Icons.shopping_bag_rounded),
                    ),
                  ],
                ),

                // --- TAB CONTENT ---
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildHowToPlayTab(appColors),
                      _buildEconomyTab(appColors),
                      _buildStoreTipsTab(appColors),
                    ],
                  ),
                ),

                // --- FOOTER BUTTON ---
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: appColors.primary.withOpacity(0.4),
                      ),
                      child: Text(
                        "ĐÃ HIỂU, CHƠI NGAY!",
                        style: TextStyle(
                          color: appColors.textLight,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS THÀNH PHẦN ---

  Widget _buildHeader(BuildContext context, AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appColors.primary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              "TRUNG TÂM HUẤN LUYỆN",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: appColors.primary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 48), // Cân bằng với nút back
        ],
      ),
    );
  }

  // TAB 1: CÁCH CHƠI
  Widget _buildHowToPlayTab(AppColors appColors) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard(
          appColors,
          icon: Icons.grid_view_rounded,
          title: "Giải Các Từ Phụ",
          desc:
              "Mỗi màn chơi có nhiều từ phụ hàng ngang. Hãy dùng bàn phím để điền chính xác các chữ cái.",
        ),
        _buildInfoCard(
          appColors,
          icon: Icons.ads_click_rounded,
          title: "Ô Trích Xuất Ký Tự",
          desc:
              "Mỗi từ phụ có một ô đặc biệt (viền đậm). Khi giải đúng, chữ cái tại ô này sẽ bay lên hàng dọc.",
        ),
        _buildInfoCard(
          appColors,
          icon: Icons.auto_fix_high_rounded,
          title: "Tìm Từ Khóa Chính",
          desc:
              "Nhiệm vụ cuối cùng là hoàn thành Từ Khóa Chính (Target) ở trên cùng từ các mảnh ghép thu thập được.",
          isHighlight: true,
        ),
      ],
    );
  }

  // TAB 2: KINH TẾ (VÀNG)
  Widget _buildEconomyTab(AppColors appColors) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard(
          appColors,
          icon: Icons.workspace_premium_rounded,
          title: "Thưởng Vượt Ải",
          desc:
              "Giải màn chơi càng nhanh và ít dùng gợi ý, bạn sẽ nhận được càng nhiều Vàng (lên tới +20 🪙).",
        ),
        _buildInfoCard(
          appColors,
          icon: Icons.stars_rounded,
          title: "Siêu Cúp Chuỗi (Journey)",
          desc:
              "Hoàn thành các cột mốc (10, 25, 50... màn) để nhận số lượng Vàng khổng lồ và Danh hiệu mới.",
        ),
        _buildInfoCard(
          appColors,
          icon: Icons.translate_rounded,
          title: "Hỗ Trợ Dịch Thuật",
          desc:
              "Bấm vào biểu tượng dịch tại Clue để xem nghĩa tiếng Việt trong 3 giây. Hoàn toàn miễn phí!",
        ),
      ],
    );
  }

  // TAB 3: CỬA HÀNG & MẸO
  Widget _buildStoreTipsTab(AppColors appColors) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard(
          appColors,
          icon: Icons.lightbulb_circle_rounded,
          title: "Sử Dụng Gợi Ý (Hint)",
          desc:
              "Khi gặp từ khó, hãy bấm Bóng Đèn. Hệ thống sẽ điền hộ bạn 1 chữ cái đúng nhất.",
        ),
        _buildInfoCard(
          appColors,
          icon: Icons.shopping_cart_checkout_rounded,
          title: "Ghé Thăm Cửa Hàng",
          desc:
              "Dùng Vàng tích lũy để mua các gói Gợi Ý. Mua gói càng lớn, giá càng rẻ!",
        ),
        _buildInfoCard(
          appColors,
          icon: Icons.psychology_rounded,
          title: "Mẹo Nhỏ",
          desc:
              "Đôi khi hãy nhìn vào Từ Khóa Chính trước để đoán ngược lại các từ phụ còn thiếu nhé!",
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    AppColors appColors, {
    required IconData icon,
    required String title,
    required String desc,
    bool isHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isHighlight
            ? appColors.primary.withOpacity(0.1)
            : appColors.defaultTile.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlight
              ? appColors.primary
              : appColors.textMain.withOpacity(0.05),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: appColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: appColors.secondary, size: 26),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: appColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 14,
                    color: appColors.textMain.withOpacity(0.8),
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
