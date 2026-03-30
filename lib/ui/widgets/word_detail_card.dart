import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/services/tts_service.dart';
import '../../data/models/learned_word.dart';

class WordDetailCard {
  static void show(BuildContext context, LearnedWord word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildCardContent(context, word);
      },
    );
  }

  static Widget _buildCardContent(BuildContext context, LearnedWord word) {
    return Container(
      padding: const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 35),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
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
                color: Colors.grey.shade300,
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
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildTypeBadge(word.type),
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
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.primary,
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
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- PHẦN MỚI THÊM: NGHĨA TIẾNG VIỆT (TRANSLATION) ---
          // Kiểm tra nếu có dữ liệu tiếng Việt thì mới hiển thị khối này
          if (word.translation.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50, // Màu nền xanh nhạt dịu mắt
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.translate_rounded,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      word.translation,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800, // Chữ màu xanh đậm dễ đọc
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // --- KẾT THÚC PHẦN MỚI THÊM ---
          const Divider(color: AppColors.bgEnd, thickness: 2, height: 1),
          const SizedBox(height: 25),

          // 4. Phần Định nghĩa (Definition - Tiếng Anh)
          _buildSectionTitle(
            Icons.menu_book_rounded,
            "DEFINITION",
            AppColors.secondary,
          ),
          const SizedBox(height: 10),
          Text(
            word.definition,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textMain,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 25),

          // 5. Phần Ví dụ (Example)
          _buildSectionTitle(
            Icons.chat_bubble_outline_rounded,
            "EXAMPLE",
            Colors.green.shade600,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200, width: 2),
            ),
            child: Text(
              '“${word.example}”',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green.shade800,
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
                backgroundColor: AppColors.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "GOT IT!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
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
  static Widget _buildTypeBadge(String type) {
    Color bgColor = AppColors.secondary.withOpacity(0.2);
    Color textColor = AppColors.secondary;

    String typeLower = type.toLowerCase();
    if (typeLower.contains("verb")) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade700;
    } else if (typeLower.contains("adj")) {
      bgColor = Colors.purple.shade100;
      textColor = Colors.purple.shade700;
    } else if (type == "Target Word") {
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade900;
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
