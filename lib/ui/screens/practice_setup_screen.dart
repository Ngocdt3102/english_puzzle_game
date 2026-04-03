import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/game_provider.dart';
import '../../logic/practice_provider.dart';
import 'practice_screen.dart';

class PracticeSetupScreen extends StatefulWidget {
  const PracticeSetupScreen({Key? key}) : super(key: key);

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  PracticeScope _selectedScope = PracticeScope.all;
  String? _selectedTopic;
  ExerciseType _selectedType = ExerciseType.multipleChoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final unlockedWords = gameProvider.unlockedWords;

    // THUẬT TOÁN ĐẾM TỪ THEO CHỦ ĐỀ
    final Map<String, int> topicCounts = {};
    for (var w in unlockedWords) {
      topicCounts[w.topic] = (topicCounts[w.topic] ?? 0) + 1;
    }

    // Chỉ lấy những chủ đề có >= 30 từ vựng
    final List<String> qualifiedTopics = topicCounts.entries
        .where((e) => e.value >= PracticeProvider.minWordsToUnlock)
        .map((e) => e.key)
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'THIẾT LẬP LUYỆN TẬP',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN 1: PHẠM VI TỪ VỰNG ---
            Text(
              '1. Phạm Vi Từ Vựng',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  RadioListTile<PracticeScope>(
                    title: Text(
                      'Tất cả chủ đề ngẫu nhiên',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    value: PracticeScope.all,
                    groupValue: _selectedScope,
                    activeColor: colorScheme.primary,
                    onChanged: (val) => setState(() => _selectedScope = val!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<PracticeScope>(
                    title: Text(
                      'Chỉ ôn 1 chủ đề cụ thể',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        // Nếu không đủ điều kiện, chữ xám đi
                        color: qualifiedTopics.isEmpty
                            ? theme.disabledColor
                            : colorScheme.onSurface,
                      ),
                    ),
                    subtitle: qualifiedTopics.isEmpty
                        ? Text(
                            'Bạn chưa có chủ đề nào đạt đủ ${PracticeProvider.minWordsToUnlock} từ vựng',
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    value: PracticeScope.byTopic,
                    groupValue: _selectedScope,
                    activeColor: colorScheme.primary,
                    // KHÓA NÚT CHỌN NẾU KHÔNG CÓ CHỦ ĐỀ NÀO ĐẠT CHUẨN
                    onChanged: qualifiedTopics.isEmpty
                        ? null
                        : (val) {
                            setState(() {
                              _selectedScope = val!;
                              if (_selectedTopic == null &&
                                  qualifiedTopics.isNotEmpty) {
                                _selectedTopic = qualifiedTopics.first;
                              }
                            });
                          },
                  ),
                  // Dropdown chọn chủ đề
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _selectedScope == PracticeScope.byTopic ? 70 : 0,
                    curve: Curves.easeInOut,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedTopic,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                          ),
                          dropdownColor: theme.cardColor,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          items: qualifiedTopics.map((topic) {
                            // Hiển thị tên chủ đề kèm số lượng từ
                            return DropdownMenuItem(
                              value: topic,
                              child: Text('$topic (${topicCounts[topic]} từ)'),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedTopic = val),
                          hint: Text(
                            'Chọn chủ đề...',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- PHẦN 2: DẠNG BÀI TẬP ---
            Text(
              '2. Dạng Bài Tập',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildTypeCard(
              title: 'Trắc nghiệm (Multiple Choice)',
              subtitle: 'Chọn nghĩa Tiếng Việt đúng nhất.',
              icon: Icons.checklist_rounded,
              type: ExerciseType.multipleChoice,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildTypeCard(
              title: 'Luyện nghe (Listening)',
              subtitle: 'Nghe AI đọc và gõ lại từ Tiếng Anh.',
              icon: Icons.headphones_rounded,
              type: ExerciseType.listening,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildTypeCard(
              title: 'Luyện viết (Writing)',
              subtitle: 'Đọc nghĩa, phiên âm và gõ lại từ.',
              icon: Icons.keyboard_rounded,
              type: ExerciseType.writing,
              theme: theme,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            onPressed: () {
              if (_selectedScope == PracticeScope.byTopic &&
                  _selectedTopic == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng chọn một chủ đề!')),
                );
                return;
              }

              final practiceProvider = Provider.of<PracticeProvider>(
                context,
                listen: false,
              );
              practiceProvider.setScope(_selectedScope);
              practiceProvider.setTopic(_selectedTopic ?? "");
              practiceProvider.setType(_selectedType);
              practiceProvider.startPractice(unlockedWords);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PracticeScreen()),
              );
            },
            child: const Text(
              'BẮT ĐẦU LUYỆN TẬP',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required ExerciseType type,
    required ThemeData theme,
  }) {
    bool isSelected = _selectedType == type;
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
