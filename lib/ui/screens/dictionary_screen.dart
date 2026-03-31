import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../data/models/learned_word.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';
import '../widgets/word_detail_card.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String searchQuery = "";
  String selectedTopic = "All"; // Mặc định hiển thị tất cả

  @override
  Widget build(BuildContext context) {
    // 1. LẤY DỮ LIỆU VÀ BỘ MÀU THEME ĐỘNG
    final unlockedWords = context.watch<GameProvider>().unlockedWords;
    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    // 2. TỰ ĐỘNG TRÍCH XUẤT DANH SÁCH CHỦ ĐỀ TỪ TỪ VỰNG ĐÃ HỌC
    // (Sử dụng Set để loại bỏ các chủ đề trùng lặp)
    final List<String> availableTopics = ["All"];
    for (var word in unlockedWords) {
      if (!availableTopics.contains(word.topic)) {
        availableTopics.add(word.topic);
      }
    }

    // 3. LOGIC LỌC TỪ VỰNG (Theo Chủ đề + Tìm kiếm)
    final filteredWords = unlockedWords.where((word) {
      // Kiểm tra xem từ có khớp với Chủ đề đang chọn không
      final matchesTopic =
          selectedTopic == "All" || word.topic == selectedTopic;

      // Kiểm tra xem từ có khớp với Thanh tìm kiếm không (Tìm cả tiếng Anh lẫn tiếng Việt)
      final searchLower = searchQuery.toLowerCase();
      final matchesSearch =
          word.word.toLowerCase().contains(searchLower) ||
          word.translation.toLowerCase().contains(searchLower);

      return matchesTopic && matchesSearch;
    }).toList();

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

              // --- THANH TÌM KIẾM ---
              if (unlockedWords.isNotEmpty) _buildSearchBar(appColors),

              // --- THANH LỌC CHỦ ĐỀ (FILTER CHIPS) ---
              if (unlockedWords.isNotEmpty && availableTopics.length > 1)
                _buildTopicFilters(availableTopics, appColors),

              // --- DANH SÁCH TỪ VỰNG (ĐÃ LỌC) ---
              Expanded(
                child: unlockedWords.isEmpty
                    ? _buildEmptyState(appColors)
                    : filteredWords.isEmpty
                    ? _buildNoResultsState(appColors) // Khi tìm không ra từ
                    : _buildWordList(filteredWords, appColors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader(
    BuildContext context,
    int totalWords,
    AppColors appColors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
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
          Expanded(
            child: Text(
              "DICTIONARY",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: appColors.primary,
                letterSpacing: 1.5,
              ),
            ),
          ),
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

  Widget _buildSearchBar(AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: TextStyle(
          color: appColors.textMain,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: "Tìm kiếm từ vựng...",
          hintStyle: TextStyle(color: appColors.textMain.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search_rounded, color: appColors.primary),
          filled: true,
          fillColor: appColors.defaultTile.withOpacity(0.8),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTopicFilters(List<String> topics, AppColors appColors) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          final isSelected = topic == selectedTopic;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTopic = topic;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? appColors.primary : appColors.defaultTile,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? appColors.primary
                      : appColors.primary.withOpacity(0.2),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: appColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                topic,
                style: TextStyle(
                  color: isSelected ? appColors.textLight : appColors.textMain,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordList(List<LearnedWord> words, AppColors appColors) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final isTarget =
            word.type == "Target Word" ||
            word.type == "Noun"; // Điều chỉnh logic này nếu cần

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
                            word.translation.isNotEmpty
                                ? word.translation
                                : word.definition,
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

  Widget _buildEmptyState(AppColors appColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 80,
            color: appColors.primary.withOpacity(0.5),
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

  Widget _buildNoResultsState(AppColors appColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 60,
            color: appColors.textMain.withOpacity(0.3),
          ),
          const SizedBox(height: 15),
          Text(
            "Không tìm thấy từ vựng",
            style: TextStyle(
              fontSize: 18,
              color: appColors.textMain.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
