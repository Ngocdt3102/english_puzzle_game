import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/game_provider.dart';
import '../../logic/practice_provider.dart';
import 'practice_setup_screen.dart';
import 'topic_selection_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final unlockedWordsCount = Provider.of<GameProvider>(
      context,
    ).unlockedWords.length;

    // Tự động sử dụng số 30 từ Provider
    final bool isPracticeLocked =
        unlockedWordsCount < PracticeProvider.minWordsToUnlock;
    final int wordsNeeded =
        PracticeProvider.minWordsToUnlock - unlockedWordsCount;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'CHỌN CHẾ ĐỘ',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeCard(
              context: context,
              title: 'Play Game',
              subtitle: 'Vượt ải giải đố, ghép chữ & kiếm xu!',
              icon: Icons.videogame_asset_rounded,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              contentColor: colorScheme.onPrimary,
              isLocked: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TopicSelectionScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildModeCard(
              context: context,
              title: 'Practice Mode',
              subtitle: isPracticeLocked
                  ? 'Cần thu thập thêm $wordsNeeded từ vựng để mở khóa'
                  : 'Ôn tập siêu tốc kho từ vựng đã mở khóa',
              icon: isPracticeLocked
                  ? Icons.lock_rounded
                  : Icons.school_rounded,
              gradient: LinearGradient(
                colors: isPracticeLocked
                    ? [
                        theme.disabledColor,
                        theme.disabledColor.withOpacity(0.5),
                      ]
                    : [
                        colorScheme.secondary,
                        colorScheme.secondary.withOpacity(0.6),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              contentColor: isPracticeLocked
                  ? colorScheme.onSurface.withOpacity(0.6)
                  : colorScheme.onSecondary,
              isLocked: isPracticeLocked,
              onTap: () {
                if (isPracticeLocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Bạn cần giải đố để thu thập ít nhất ${PracticeProvider.minWordsToUnlock} từ vựng trước khi có thể Luyện tập!',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: colorScheme.error,
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PracticeSetupScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required Color contentColor,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (!isLocked)
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 150,
                color: contentColor.withOpacity(isLocked ? 0.1 : 0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: contentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, size: 36, color: contentColor),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: contentColor,
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.lock, color: contentColor, size: 20),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: contentColor.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
