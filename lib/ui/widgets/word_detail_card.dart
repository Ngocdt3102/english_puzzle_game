import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/services/tts_service.dart';
import '../../data/models/learned_word.dart';
import '../../logic/settings_provider.dart';

class WordDetailCard {
  static void show(BuildContext context, LearnedWord word) {
    final settings = context.read<SettingsProvider>();

    // Nếu bật Tự động phát âm -> Đọc ngay từ đó
    if (settings.isSoundEnabled) {
      TTSService.speak(word.word);
    }

    // Rung phản hồi nhẹ khi mở thẻ
    if (settings.isHapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    // --- 2 BIẾN QUẢN LÝ TRẠNG THÁI MỞ RỘNG CHO 2 HỘP ---
    bool isDefExpanded = false;
    bool isExExpanded = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final themeIndex = bottomSheetContext
            .read<SettingsProvider>()
            .themeIndex;
        final appColors = AppColors.getTheme(themeIndex);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildCardContent(
              context,
              word,
              appColors,
              isDefExpanded,
              isExExpanded,
              (val) => setState(() => isDefExpanded = val),
              (val) => setState(() => isExExpanded = val),
              settings,
            );
          },
        );
      },
    );
  }

  static Widget _buildCardContent(
    BuildContext context,
    LearnedWord word,
    AppColors appColors,
    bool isDefExpanded,
    bool isExExpanded,
    Function(bool) toggleDef,
    Function(bool) toggleEx,
    SettingsProvider settings,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 35),
      decoration: BoxDecoration(
        color: appColors.defaultTile,
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
                color: appColors.textMain.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            color: appColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      _buildTypeBadge(word.type, appColors),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. Phiên âm + NÚT BẤM LOA
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => TTSService.speak(word.word),
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: appColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.volume_up_rounded,
                              color: appColors.primary,
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
                          color: appColors.textMain.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- NGHĨA NGẮN GỌN (Luôn hiển thị) ---
                  if (word.translation.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: appColors.selectedTile,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: appColors.primary.withOpacity(0.3),
                        ),
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

                  Divider(
                    color: appColors.textMain.withOpacity(0.1),
                    thickness: 2,
                    height: 1,
                  ),
                  const SizedBox(height: 25),

                  // --- 4. HỘP ĐỊNH NGHĨA (ACCORDION) ---
                  _buildSectionTitle(
                    Icons.menu_book_rounded,
                    "DEFINITION",
                    appColors.secondary,
                  ),
                  const SizedBox(height: 10),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: appColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: appColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  word.definition,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: appColors.textMain,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (word.definitionVi.isNotEmpty)
                                _buildTranslateToggle(
                                  isExpanded: isDefExpanded,
                                  appColors: appColors,
                                  onTap: () {
                                    if (settings.isHapticEnabled)
                                      HapticFeedback.lightImpact();
                                    toggleDef(!isDefExpanded);
                                  },
                                ),
                            ],
                          ),
                          if (isDefExpanded &&
                              word.definitionVi.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                color: appColors.primary.withOpacity(0.2),
                                height: 1,
                              ),
                            ),
                            Text(
                              word.definitionVi,
                              style: TextStyle(
                                fontSize: 15,
                                color: appColors.textMain.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- 5. HỘP VÍ DỤ (ACCORDION) ---
                  _buildSectionTitle(
                    Icons.chat_bubble_outline_rounded,
                    "EXAMPLE",
                    appColors.correctTile,
                  ),
                  const SizedBox(height: 10),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: appColors.correctTile.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: appColors.correctTile.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  '“${word.example}”',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: appColors.textMain,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              if (word.exampleVi.isNotEmpty)
                                _buildTranslateToggle(
                                  isExpanded: isExExpanded,
                                  appColors: appColors,
                                  onTap: () {
                                    if (settings.isHapticEnabled)
                                      HapticFeedback.lightImpact();
                                    toggleEx(!isExExpanded);
                                  },
                                ),
                            ],
                          ),
                          if (isExExpanded && word.exampleVi.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                color: appColors.correctTile.withOpacity(0.3),
                                height: 1,
                              ),
                            ),
                            Text(
                              '“${word.exampleVi}”',
                              style: TextStyle(
                                fontSize: 15,
                                color: appColors.textMain.withOpacity(0.8),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // 6. Từ Đồng Nghĩa / Trái Nghĩa (V2) - Luôn hiển thị nếu có
                  if (word.synonyms.isNotEmpty || word.antonyms.isNotEmpty) ...[
                    const SizedBox(height: 25),
                    _buildSectionTitle(
                      Icons.hub_rounded,
                      "SYNONYMS & ANTONYMS",
                      Colors.orangeAccent,
                    ),
                    const SizedBox(height: 15),
                    if (word.synonyms.isNotEmpty)
                      _buildTagList(
                        "Đồng nghĩa:",
                        word.synonyms,
                        appColors.correctTile,
                        appColors,
                      ),
                    if (word.synonyms.isNotEmpty && word.antonyms.isNotEmpty)
                      const SizedBox(height: 12),
                    if (word.antonyms.isNotEmpty)
                      _buildTagList(
                        "Trái nghĩa:",
                        word.antonyms,
                        Colors.redAccent,
                        appColors,
                      ),
                  ],

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),

          // 7. Nút Đóng (Ghim dưới cùng, không bị cuộn)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.primary,
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
                  color: appColors.textLight,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NÚT DỊCH THUẬT GÓC PHẢI DÙNG CHUNG CHO CÁC HỘP ---
  static Widget _buildTranslateToggle({
    required bool isExpanded,
    required AppColors appColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isExpanded
              ? appColors.secondary
              : appColors.primary.withOpacity(0.15),
        ),
        child: Icon(
          isExpanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.translate_rounded,
          size: 20,
          color: isExpanded ? appColors.textLight : appColors.primary,
        ),
      ),
    );
  }

  // --- Widget vẽ danh sách nhãn (Dùng cho từ đồng/trái nghĩa) ---
  static Widget _buildTagList(
    String label,
    List<String> items,
    Color tagColor,
    AppColors appColors,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              label,
              style: TextStyle(
                color: appColors.textMain.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tagColor.withOpacity(0.5)),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    color: tagColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  static Widget _buildTypeBadge(String type, AppColors appColors) {
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
