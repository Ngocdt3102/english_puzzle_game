import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../data/models/topic_model.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  bool isLoading = false;

  void _onTopicTapped(
    BuildContext context,
    TopicModel topic,
    SettingsProvider settings,
  ) async {
    if (isLoading) return;

    // Rung phản hồi khi chọn chủ đề
    if (settings.isHapticEnabled) HapticFeedback.lightImpact();

    setState(() => isLoading = true);

    try {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);

      // Nạp dữ liệu với khóa kết hợp
      await gameProvider.loadTopicData(topic.id, topic.fileName);

      if (mounted) {
        setState(() => isLoading = false);
        Navigator.pushNamed(context, '/level_selection');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi tải dữ liệu: $e. Hãy kiểm tra lại file ${topic.fileName}.json',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- LẤY BỘ MÀU THEME ĐỘNG (TẮC KÈ HOA) ---
    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    final gameProvider = context.watch<GameProvider>();
    final userCompletedLevels = gameProvider.completedLevels;

    return Scaffold(
      body: Container(
        // Phủ nền Gradient đồng bộ với toàn App
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [appColors.bgStart, appColors.bgEnd],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // --- HEADER TÙY CHỈNH ---
                  Padding(
                    padding: const EdgeInsets.all(20.0),
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
                            "CHOOSE TOPIC",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: appColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 48,
                        ), // Cân bằng không gian với nút Back
                      ],
                    ),
                  ),

                  // --- DANH SÁCH CHỦ ĐỀ ---
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7, // Kéo dài thẻ ra một chút
                          ),
                      itemCount: appTopics.length,
                      itemBuilder: (context, index) {
                        final topic = appTopics[index];

                        // TÍNH TOÁN TIẾN ĐỘ THẬT (COMPOSITE KEY)
                        int actualCompleted = topic.levelIds
                            .where(
                              (id) => userCompletedLevels.contains(
                                "${topic.id}_$id",
                              ),
                            )
                            .length;

                        if (actualCompleted > topic.totalLevels) {
                          actualCompleted = topic.totalLevels;
                        }

                        final progress = actualCompleted / topic.totalLevels;
                        final isCompleted =
                            actualCompleted == topic.totalLevels;

                        return _buildTopicCard(
                          topic,
                          actualCompleted,
                          progress,
                          isCompleted,
                          appColors,
                          settings,
                        );
                      },
                    ),
                  ),
                ],
              ),

              // --- LOADING OVERLAY ---
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: appColors.defaultTile,
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        color: appColors.secondary,
                        strokeWidth: 4,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET VẼ THẺ CHỦ ĐỀ (ĐÃ THIẾT KẾ LẠI) ---
  Widget _buildTopicCard(
    TopicModel topic,
    int actualCompleted,
    double progress,
    bool isCompleted,
    AppColors appColors,
    SettingsProvider settings,
  ) {
    return GestureDetector(
      onTap: () => _onTopicTapped(context, topic, settings),
      child: Container(
        decoration: BoxDecoration(
          color: appColors.defaultTile,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isCompleted
                ? appColors.secondary.withOpacity(0.5)
                : appColors.primary.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isCompleted ? appColors.secondary : appColors.primary)
                  .withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // Dùng ClipRRect để hình nền mờ không bị tràn ra ngoài góc bo tròn
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              // --- HÌNH NỀN MỜ (WATERMARK) ---
              Positioned(
                right: -20,
                bottom: -20,
                child: Transform.rotate(
                  angle: -pi / 12,
                  child: Icon(topic.icon, size: 24, color: appColors.primary),
                ),
              ),

              // --- NỘI DUNG CHÍNH ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon nhỏ trên cùng
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: appColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            topic.icon,
                            size: 24,
                            color: appColors.primary,
                          ),
                        ),

                        // Tích xanh nếu hoàn thành
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: appColors.secondary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              color: appColors.secondary,
                              size: 20,
                            ),
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Tiêu đề Chủ đề
                    Text(
                      topic.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: appColors.primary,
                        letterSpacing: 1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Tiến độ chơi
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: appColors.textMain.withOpacity(0.5),
                              ),
                            ),
                            Text(
                              '$actualCompleted/${topic.totalLevels}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? appColors.secondary
                                    : appColors.textMain.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: appColors.primary.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted
                                  ? appColors.secondary
                                  : appColors.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
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
}
