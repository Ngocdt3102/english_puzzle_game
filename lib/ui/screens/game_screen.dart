import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart'; // Mình giữ nguyên đường dẫn import màu sắc của bạn
import '../../logic/game_provider.dart';
import '../widgets/breathing_glow_widget.dart';
import '../widgets/clue_panel.dart';
import '../widgets/crossword_grid.dart';
import '../widgets/custom_keyboard.dart';
import '../widgets/flying_letter_widget.dart';
import '../widgets/main_word_view.dart';
import '../widgets/victory_overlay.dart';
import 'dictionary_screen.dart'; // Nhớ import màn hình từ điển

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lấy instance của Provider
    final gameProvider = context.watch<GameProvider>();

    // 2. Lắng nghe các trạng thái cần thiết
    final isLevelCompleted = gameProvider.isLevelCompleted;
    final isKeyboardVisible = gameProvider.isKeyboardVisible;

    // --- BƯỚC PHÒNG THỦ QUAN TRỌNG ---
    // NẾU DỮ LIỆU ĐANG NẠP, HIỆN LOADING (CHẶN ĐỨNG LỖI OVERFLOW)
    if (gameProvider.currentLevel == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgStart,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      // 2. Dùng Stack để có thể phủ màn hình chúc mừng lên trên màn hình Game
      body: Stack(
        children: [
          // --- LỚP DƯỚI: GIAO DIỆN GAME BÌNH THƯỜNG ---
          Container(
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
                  _buildHeader(context), // Truyền context vào để đọc Provider
                  MainWordView(
                    key: ValueKey('main_${gameProvider.currentLevelId}'),
                  ),
                  CluePanel(
                    key: ValueKey('clue_${gameProvider.currentLevelId}'),
                  ),
                  CrosswordGrid(
                    key: ValueKey('grid_${gameProvider.currentLevelId}'),
                  ),

                  // Bọc CustomKeyboard vào AnimatedSize để có hiệu ứng trượt mượt mà
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isKeyboardVisible
                        ? const CustomKeyboard()
                        : const SizedBox(
                            width: double.infinity,
                            height: 0,
                          ), // Thu lại bằng 0 khi ẩn
                  ),
                ],
              ),
            ),
          ),

          if (gameProvider.currentFlyingData != null)
            FlyingLetterWidget(data: gameProvider.currentFlyingData!),

          // --- LỚP TRÊN: HIỆU ỨNG CHÚC MỪNG (VICTORY OVERLAY) ---
          if (isLevelCompleted) const VictoryOverlay(),
        ],
      ),
    );
  }

  // Cập nhật Header để hiển thị số Level động và thêm Nút Từ Điển
  Widget _buildHeader(BuildContext context) {
    // Lấy ID màn chơi hiện tại
    final levelId = context.select((GameProvider p) => p.currentLevelId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // SỬA ĐỔI: Dùng Row để gộp Nút Thoát (X) và Nút Từ Điển đứng cạnh nhau
          Row(
            children: [
              // 1. NÚT THOÁT GAME
              GestureDetector(
                onTap: () {
                  Navigator.pop(
                    context,
                  ); // Lệnh này giúp thoát về màn hình Home
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10), // Khoảng cách giữa 2 nút
              // 2. NÚT MỞ TỪ ĐIỂN
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DictionaryScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          // HIỂN THỊ LEVEL ĐỘNG
          Text(
            "LEVEL $levelId",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),

          // NÚT SỬ DỤNG GỢI Ý (HINT) KÈM HIỆU ỨNG LÓE SÁNG
          Consumer<GameProvider>(
            builder: (context, provider, child) {
              bool outOfHints = provider.hints <= 0;

              return BreathingGlowWidget(
                glowColor: Colors.amberAccent, // Hào quang màu vàng ma thuật
                isEnabled: !outOfHints, // Chỉ phát sáng khi còn gợi ý
                child: GestureDetector(
                  onTap: () => provider.useHint(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: outOfHints
                          ? Colors.grey.shade400
                          : AppColors.secondary,
                      borderRadius: BorderRadius.circular(15),
                      // Đã xóa boxShadow tĩnh ở đây để nhường chỗ cho bóng động của BreathingGlowWidget
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${provider.hints}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // // Thêm Widget Victory Chúc Mừng
  // Widget _buildVictoryOverlay(BuildContext context) {
  //   final provider = context.read<GameProvider>();
  //   final mainWord = provider.currentLevel?.mainWord.word ?? "";
  //   final definition = provider.currentLevel?.mainWord.definition ?? "";

  //   return Container(
  //     color: Colors.black.withOpacity(0.6), // Phủ nền đen mờ
  //     alignment: Alignment.center,
  //     child: TweenAnimationBuilder<double>(
  //       tween: Tween(begin: 0.0, end: 1.0),
  //       duration: const Duration(milliseconds: 600),
  //       curve: Curves.elasticOut, // Hiệu ứng bật nảy tưng tưng
  //       builder: (context, value, child) {
  //         return Transform.scale(
  //           scale: value,
  //           child: Container(
  //             margin: const EdgeInsets.symmetric(horizontal: 30),
  //             padding: const EdgeInsets.all(30),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(25),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: AppColors.secondary.withOpacity(0.5),
  //                   blurRadius: 30,
  //                   spreadRadius: 5,
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 const Text(
  //                   "AWESOME!",
  //                   style: TextStyle(
  //                     fontSize: 28,
  //                     fontWeight: FontWeight.w900,
  //                     color: AppColors.secondary,
  //                     letterSpacing: 2,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 10),
  //                 const Text(
  //                   "You found the target word:",
  //                   style: TextStyle(fontSize: 14, color: Colors.black54),
  //                 ),
  //                 const SizedBox(height: 10),

  //                 // Chữ khóa chính
  //                 Text(
  //                   mainWord,
  //                   style: const TextStyle(
  //                     fontSize: 36,
  //                     fontWeight: FontWeight.w900,
  //                     color: AppColors.primary,
  //                     letterSpacing: 4,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 15),

  //                 // Hiển thị định nghĩa tiếng Anh
  //                 Container(
  //                   padding: const EdgeInsets.all(12),
  //                   decoration: BoxDecoration(
  //                     color: AppColors.bgStart,
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   child: Text(
  //                     definition,
  //                     textAlign: TextAlign.center,
  //                     style: const TextStyle(
  //                       fontSize: 16,
  //                       color: AppColors.primary,
  //                       fontStyle: FontStyle.italic,
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 30),

  //                 // Nút Next Level
  //                 SizedBox(
  //                   width: double.infinity,
  //                   height: 55,
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: AppColors.primary,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(15),
  //                       ),
  //                       elevation: 5,
  //                     ),
  //                     onPressed: () => provider.loadNextLevel(),
  //                     child: const Text(
  //                       "NEXT LEVEL",
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.white,
  //                         letterSpacing: 1.5,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}
