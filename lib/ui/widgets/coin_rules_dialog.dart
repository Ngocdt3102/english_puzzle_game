import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class CoinRulesDialog {
  static void show(BuildContext context, AppColors appColors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appColors.defaultTile,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: appColors.primary.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: Colors.amber,
                size: 45,
              ),
              const SizedBox(height: 10),
              Text(
                "BÍ KÍP SĂN VÀNG",
                style: TextStyle(
                  color: appColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                _buildModernRule(
                  appColors,
                  icon: Icons.auto_awesome_rounded,
                  title: "Hoàn Thành Màn Chơi",
                  detail: "Tùy thuộc vào độ nhạy bén của bạn:",
                  bonus: [
                    "Tuyệt đỉnh (0 Gợi ý): +20 🪙",
                    "Khéo léo (1 Gợi ý): +18 🪙",
                    "Cố gắng (2 Gợi ý): +15 🪙",
                    "Vừa đủ (3 Gợi ý): +10 🪙",
                  ],
                  footer: "Dùng trên 3 gợi ý sẽ không nhận thưởng màn.",
                ),
                _buildModernRule(
                  appColors,
                  icon: Icons.extension_rounded,
                  title: "Giải Từ Khóa Phụ",
                  detail: "Mỗi từ phụ giải được sẽ cộng thêm:",
                  bonus: [
                    "Tự thân vận động: +5 🪙",
                    "Dùng quyền trợ giúp: +2 🪙",
                  ],
                ),
                _buildModernRule(
                  appColors,
                  icon: Icons.emoji_events_rounded,
                  title: "Siêu Cúp Chuỗi",
                  detail: "Cứ mỗi 5 màn chơi hoàn tất:",
                  bonus: [
                    "Mốc 5 màn: +20 🪙",
                    "Mốc 10 màn: +50 🪙",
                    "Mốc tiếp theo: (Mốc cũ × 2) + 10",
                  ],
                  highlight: true,
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "ĐÃ HIỂU",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildModernRule(
    AppColors appColors, {
    required IconData icon,
    required String title,
    required String detail,
    required List<String> bonus,
    String? footer,
    bool highlight = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? appColors.primary.withOpacity(0.05)
            : appColors.textMain.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: highlight
            ? Border.all(color: appColors.primary.withOpacity(0.2), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: highlight ? appColors.secondary : appColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: appColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: TextStyle(
              color: appColors.textMain.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          ...bonus.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: highlight ? Colors.amber : appColors.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: appColors.textMain,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 8),
            Text(
              footer,
              style: TextStyle(
                color: Colors.redAccent.withOpacity(0.7),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
