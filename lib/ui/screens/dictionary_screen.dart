import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../data/models/learned_word.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart'; // THÊM IMPORT
import '../widgets/word_detail_card.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. LẤY DỮ LIỆU VÀ BỘ MÀU THEME ĐỘNG
    final unlockedWords = context.watch<GameProvider>().unlockedWords;
    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    return Scaffold(
      body: Container(
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
              _buildCustomHeader(context, unlockedWords.length, appColors),
              Expanded(
                child: unlockedWords.isEmpty
                    ? _buildEmptyState(appColors)
                    : _buildWordList(unlockedWords, appColors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header tùy chỉnh mang phong cách Game ---
  Widget _buildCustomHeader(
    BuildContext context,
    int totalWords,
    AppColors appColors,
  ) {
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
                color: appColors.defaultTile.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: appColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Tiêu đề
          Expanded(
            child: Text(
              "MY DICTIONARY",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: appColors.primary,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // Bộ đếm từ vựng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: appColors.secondary,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: appColors.secondary.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  color: appColors.textLight,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  "$totalWords",
                  style: TextStyle(
                    color: appColors.textLight,
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
  Widget _buildWordList(List<LearnedWord> words, AppColors appColors) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final isTarget = word.type == "Target Word";

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: appColors.defaultTile,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isTarget
                  ? appColors.secondary
                  : appColors.textMain.withOpacity(0.05),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isTarget
                    ? appColors.secondary.withOpacity(0.15)
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
              onTap: () => WordDetailCard.show(context, word),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon Phân loại
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isTarget
                            ? appColors.secondary.withOpacity(0.15)
                            : appColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isTarget ? Icons.star_rounded : Icons.bookmark_rounded,
                        color: isTarget
                            ? appColors.secondary
                            : appColors.primary,
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
                                  ? appColors.secondary
                                  : appColors.textMain,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            word.definition,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: appColors.textMain.withOpacity(0.6),
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
                      color: appColors.textMain.withOpacity(0.2),
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

  // --- Trạng thái trống ---
  Widget _buildEmptyState(AppColors appColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: appColors.defaultTile.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 80,
              color: appColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            "Nothing here yet!",
            style: TextStyle(
              fontSize: 22,
              color: appColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Solve puzzles to unlock new words\nand build your dictionary.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appColors.textMain.withOpacity(0.7),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
