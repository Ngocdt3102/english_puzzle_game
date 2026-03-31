import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';
import '../widgets/coin_rules_dialog.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final appColors = AppColors.getTheme(
      context.watch<SettingsProvider>().themeIndex,
    );

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
              _buildHeader(context, gameProvider.coins, appColors),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _storeItem(
                      context,
                      gameProvider,
                      "Gói Khởi Đầu",
                      "5 Gợi ý",
                      50,
                      5,
                      Icons.lightbulb_outline,
                      Colors.blue,
                      appColors,
                    ),
                    _storeItem(
                      context,
                      gameProvider,
                      "Gói Thợ Săn",
                      "15 Gợi ý",
                      135,
                      15,
                      Icons.tips_and_updates_rounded, // Đã sửa
                      Colors.purple,
                      appColors,
                    ),
                    _storeItem(
                      context,
                      gameProvider,
                      "Gói Học Giả",
                      "35 Gợi ý",
                      280,
                      35,
                      Icons.psychology_rounded, // Đã sửa
                      Colors.orange,
                      appColors,
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

  Widget _buildHeader(BuildContext context, int coins, AppColors appColors) {
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
          const Spacer(),
          GestureDetector(
            onTap: () => CoinRulesDialog.show(context, appColors),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: appColors.defaultTile,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$coins",
                    style: TextStyle(
                      color: appColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.help_outline,
                    size: 14,
                    color: appColors.primary.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeItem(
    BuildContext context,
    GameProvider provider,
    String title,
    String desc,
    int cost,
    int amount,
    IconData icon,
    Color color,
    AppColors appColors,
  ) {
    bool canBuy = provider.coins >= cost;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors.defaultTile,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appColors.primary,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(color: appColors.textMain.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canBuy ? appColors.secondary : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: canBuy ? () => provider.buyItem(cost, amount) : null,
            child: Text(
              "$cost 🪙",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
