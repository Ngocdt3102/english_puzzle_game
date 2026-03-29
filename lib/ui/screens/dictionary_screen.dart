import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../data/models/learned_word.dart';
import '../../logic/game_provider.dart';
import '../widgets/word_detail_card.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách từ đã mở khóa từ bộ não GameProvider
    final unlockedWords = context.watch<GameProvider>().unlockedWords;

    return Scaffold(
      body: Container(
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
              _buildCustomHeader(context, unlockedWords.length),
              Expanded(
                child: unlockedWords.isEmpty
                    ? _buildEmptyState()
                    : _buildWordList(unlockedWords),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header tùy chỉnh mang phong cách Game ---
  Widget _buildCustomHeader(BuildContext context, int totalWords) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          // Nút Back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Tiêu đề
          const Expanded(
            child: Text(
              "MY DICTIONARY",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // Bộ đếm từ vựng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  "$totalWords",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Danh sách từ vựng ---
  Widget _buildWordList(List<LearnedWord> words) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn mượt mà của iOS
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final isTarget =
            word.type ==
            "Target Word"; // Kiểm tra xem có phải từ khóa chính không

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            // Viền nổi bật cho Từ Khóa Chính
            border: isTarget
                ? Border.all(color: AppColors.secondary, width: 2)
                : Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: isTarget
                    ? AppColors.secondary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () =>
                  WordDetailCard.show(context, word), // Gọi Bottom Sheet
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon Phân loại (Ngôi sao cho từ chính, Dấu trang cho từ phụ)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isTarget
                            ? AppColors.secondary.withOpacity(0.15)
                            : AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isTarget ? Icons.star_rounded : Icons.bookmark_rounded,
                        color: isTarget
                            ? AppColors.secondary
                            : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Thông tin từ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word.word,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isTarget
                                  ? AppColors.secondary
                                  : AppColors.textMain,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            word.definition,
                            maxLines: 1, // Cắt chữ nếu quá dài
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Trạng thái trống (Khi chưa chơi màn nào) ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "Nothing here yet!",
            style: TextStyle(
              fontSize: 22,
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Solve puzzles to unlock new words\nand build your dictionary.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
