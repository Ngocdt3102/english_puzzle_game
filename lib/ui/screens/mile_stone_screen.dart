import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';

class MilestoneScreen extends StatelessWidget {
  const MilestoneScreen({super.key});

  // --- THIẾT LẬP CÁC CỘT MỐC GIÁ TRỊ ---
  // Ngọc có thể thêm bớt các con số này tùy theo tổng số Level bạn có
  final List<int> milestones = const [
    10,
    25,
    50,
    100,
    200,
    350,
    500,
    750,
    1000,
  ];

  // Hàm tính thưởng Vàng dựa trên độ khó của mốc (Giá trị mốc càng cao thưởng càng đậm)
  int _calculateReward(int milestoneValue) {
    if (milestoneValue <= 10) return 50;
    if (milestoneValue <= 50) return 150;
    if (milestoneValue <= 100) return 400;
    return milestoneValue * 5; // Ví dụ: mốc 500 tặng 2500 Vàng
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();
    final appColors = AppColors.getTheme(settings.themeIndex);

    final totalSolved = gameProvider.completedLevels.length;

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
              _buildHeader(context, appColors),

              _buildProgressOverview(totalSolved, appColors),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: milestones.length,
                  itemBuilder: (context, index) {
                    final mValue = milestones[index];
                    final isReached = totalSolved >= mValue;
                    final reward = _calculateReward(mValue);

                    // Hiển thị mốc:
                    // Luôn hiện mốc đã đạt và mốc tiếp theo.
                    // Những mốc quá xa (cách 3 bậc) có thể để ẩn hoặc hiện mờ.
                    return _buildMilestoneStep(
                      value: mValue,
                      reward: reward,
                      reached: isReached,
                      appColors: appColors,
                      isLast: index == milestones.length - 1,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appColors.primary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Text(
            "HÀNH TRÌNH",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: appColors.primary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(int totalSolved, AppColors appColors) {
    String rank = "TÂN THỦ";
    IconData rankIcon = Icons.auto_awesome;
    if (totalSolved >= 100) {
      rank = "BẬC THẦY";
      rankIcon = Icons.workspace_premium;
    } else if (totalSolved >= 50) {
      rank = "CHUYÊN GIA";
      rankIcon = Icons.military_tech;
    } else if (totalSolved >= 25) {
      rank = "THỢ SĂN";
      rankIcon = Icons.shield;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors.defaultTile,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TIẾN ĐỘ TỔNG",
                  style: TextStyle(
                    color: appColors.textMain.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "$totalSolved",
                  style: TextStyle(
                    color: appColors.secondary,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Màn chơi hoàn tất",
                  style: TextStyle(
                    color: appColors.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 60,
            color: appColors.textMain.withOpacity(0.1),
          ),
          Expanded(
            child: Column(
              children: [
                Icon(
                  rankIcon,
                  color: totalSolved >= 10 ? Colors.amber : Colors.grey,
                  size: 40,
                ),
                const SizedBox(height: 5),
                Text(
                  rank,
                  style: TextStyle(
                    color: appColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneStep({
    required int value,
    required int reward,
    required bool reached,
    required AppColors appColors,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: reached ? appColors.correctTile : appColors.defaultTile,
                shape: BoxShape.circle,
                border: Border.all(
                  color: reached
                      ? Colors.white
                      : appColors.primary.withOpacity(0.2),
                  width: 3,
                ),
                boxShadow: reached
                    ? [
                        BoxShadow(
                          color: appColors.correctTile.withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: reached
                    ? const Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 28,
                      )
                    : Text(
                        "$value",
                        style: TextStyle(
                          color: appColors.primary.withOpacity(0.5),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 4,
                height: 80,
                color: reached
                    ? appColors.correctTile.withOpacity(0.5)
                    : appColors.primary.withOpacity(0.1),
              ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: reached
                  ? appColors.defaultTile
                  : appColors.defaultTile.withOpacity(0.3),
              borderRadius: BorderRadius.circular(22),
              border: reached
                  ? Border.all(
                      color: appColors.correctTile.withOpacity(0.5),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mốc Huyền Thoại $value",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: reached
                        ? appColors.primary
                        : appColors.textMain.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: reached ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "+$reward Vàng",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: reached
                            ? appColors.textMain
                            : appColors.textMain.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                if (reached)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "ĐÃ CHINH PHỤC",
                      style: TextStyle(
                        color: appColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
