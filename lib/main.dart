import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/tts_service.dart';
import 'data/repositories/level_repository.dart';
import 'logic/game_provider.dart';
import 'logic/settings_provider.dart'; // 1. IMPORT SettingsProvider
import 'ui/screens/home_screen.dart';

void main() async {
  // Đảm bảo Flutter đã sẵn sàng để gọi các dịch vụ hệ thống (như SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo dịch vụ giọng đọc
  await TTSService.init();

  // 2. Khởi tạo Repository chứa dữ liệu các màn chơi
  final levelRepository = LevelRepository();
  try {
    await levelRepository.init();
  } catch (e) {
    debugPrint("Lỗi khởi tạo dữ liệu JSON: $e");
  }

  // 3. Khởi tạo GameProvider (Xử lý logic game)
  final gameProvider = GameProvider(levelRepository);
  await gameProvider.initPrefs();

  // 4. Khởi tạo SettingsProvider (Xử lý Theme, Âm thanh, Rung)
  // Việc khởi tạo này sẽ tự động load các cài đặt cũ từ máy lên
  final settingsProvider = SettingsProvider();

  runApp(
    MultiProvider(
      providers: [
        // Dùng .value vì các Provider đã được chúng ta tạo thủ công ở trên
        ChangeNotifierProvider.value(value: gameProvider),
        ChangeNotifierProvider.value(
          value: settingsProvider,
        ), // 5. ĐÃ THÊM DÒNG NÀY
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lưu ý: Chúng ta không cần dùng appColors ở đây vì MaterialApp chỉ là lớp vỏ.
    // Màu sắc thực tế sẽ được xử lý bên trong từng màn hình bằng appColors.getTheme.

    return MaterialApp(
      title: 'Vocab Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Có thể để một seed color mặc định, nhưng UI thực tế sẽ theo AppColors của bạn
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const HomeScreen(),
    );
  }
}
