import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để dùng HapticFeedback
import 'package:provider/provider.dart'; // --- THÊM PROVIDER ---

import '../../core/constants/colors.dart';
import '../../core/services/tts_service.dart';
import '../../data/models/learned_word.dart';
import '../../logic/settings_provider.dart'; // --- THÊM SETTINGS PROVIDER ---

class WordDetailCard {
  static void show(BuildContext context, LearnedWord word) {
    // --- THÊM ĐOẠN NÀY ĐỂ ĐỌC CÀI ĐẶT TRƯỚC KHI MỞ THẺ ---
    final settings = context.read<SettingsProvider>();

    // Nếu bật Tự động phát âm -> Đọc ngay từ đó
    if (settings.isSoundEnabled) {
      TTSService.speak(word.word);
    }

    // Rung phản hồi nhẹ khi mở thẻ
    if (settings.isHapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    // ----------------------------------------------------
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        // --- 1. KÉO BỘ MÀU TỪ SETTINGS ---
        final themeIndex = context.read<SettingsProvider>().themeIndex;
        final appColors = AppColors.getTheme(themeIndex);

        // Truyền appColors xuống hàm build nội dung
        return _buildCardContent(bottomSheetContext, word, appColors);
      },
    );
  }

  // --- 2. NHẬN BIẾN appColors VÀ ÁP DỤNG ---
  static Widget _buildCardContent(
    BuildContext context,
    LearnedWord word,
    AppColors appColors,
  ) {
    return Container(
      padding: const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 35),
      decoration: BoxDecoration(
        color: appColors.defaultTile, // Tự động đổi trắng/xám tối theo Theme
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thanh kéo nhỏ (Drag Handle)
          Center(
            child: Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: appColors.textMain.withOpacity(
                  0.2,
                ), // Tự động tương phản
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // 2. Tiêu đề (Từ vựng) + Nhãn dán (Từ loại)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  word.word,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: appColors.primary, // Cập nhật màu động
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildTypeBadge(word.type, appColors), // Truyền màu xuống
            ],
          ),
          const SizedBox(height: 12),

          // 3. Phiên âm + NÚT BẤM LOA
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    TTSService.speak(word.word);
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: appColors.primary.withOpacity(
                        0.1,
                      ), // Cập nhật màu động
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volume_up_rounded,
                      color: appColors.primary, // Cập nhật màu động
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                word.phonetic,
                style: TextStyle(
                  fontSize: 20,
                  color: appColors.textMain.withOpacity(
                    0.6,
                  ), // Tự động tương phản
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- PHẦN DỊCH NGHĨA (TRANSLATION) ---
          if (word.translation.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: appColors.selectedTile, // Màu nền dịu mắt theo Theme
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.translate_rounded,
                    color: appColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      word.translation,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: appColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          Divider(color: appColors.bgEnd, thickness: 2, height: 1),
          const SizedBox(height: 25),

          // 4. Phần Định nghĩa (Definition)
          _buildSectionTitle(
            Icons.menu_book_rounded,
            "DEFINITION",
            appColors.secondary,
          ),
          const SizedBox(height: 10),
          Text(
            word.definition,
            style: TextStyle(
              fontSize: 18,
              color: appColors.textMain, // Tự động tương phản
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 25),

          // 5. Phần Ví dụ (Example)
          _buildSectionTitle(
            Icons.chat_bubble_outline_rounded,
            "EXAMPLE",
            appColors.correctTile,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: appColors.correctTile.withOpacity(0.1), // Nền trong suốt
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: appColors.correctTile.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Text(
              '“${word.example}”',
              style: TextStyle(
                fontSize: 18,
                color: appColors.textMain, // Tự động tương phản
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 35),

          // 6. Nút Đóng
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.primary, // Màu động
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "GOT IT!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: appColors.textLight, // Chữ sáng
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget phụ trợ tạo nhãn dán từ loại ---
  static Widget _buildTypeBadge(String type, AppColors appColors) {
    // Dùng màu chủ đạo và phụ của Theme thay vì fix cứng màu
    Color bgColor = appColors.secondary.withOpacity(0.2);
    Color textColor = appColors.secondary;

    String typeLower = type.toLowerCase();
    if (typeLower.contains("verb")) {
      bgColor = Colors.redAccent.withOpacity(0.2);
      textColor = Colors.redAccent;
    } else if (typeLower.contains("adj")) {
      bgColor = Colors.purpleAccent.withOpacity(0.2);
      textColor = Colors.purpleAccent;
    } else if (type == "Target Word") {
      bgColor = appColors.correctTile.withOpacity(0.2);
      textColor = appColors.correctTile;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // --- Widget phụ trợ tạo Tiêu đề phần (Section Title) ---
  static Widget _buildSectionTitle(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
