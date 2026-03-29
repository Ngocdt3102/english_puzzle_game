import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/tts_service.dart';
import 'data/repositories/level_repository.dart';
import 'logic/game_provider.dart';
import 'ui/screens/home_screen.dart'; // IMPORT FILE HOME SCREEN

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TTSService.init();

  // 1. Khởi tạo Repository chứa JSON
  final levelRepository = LevelRepository();
  try {
    await levelRepository.init();
  } catch (e) {
    debugPrint("Lỗi khởi tạo dữ liệu: $e");
  }

  // 2. Khởi tạo Provider và yêu cầu đọc dữ liệu từ ổ cứng
  final gameProvider = GameProvider(levelRepository);
  await gameProvider.initPrefs(); // <--- CHỜ ĐỌC XONG PREFS

  runApp(
    MultiProvider(
      providers: [
        // Dùng .value vì gameProvider đã được khởi tạo sẵn ở trên
        ChangeNotifierProvider.value(value: gameProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Puzzle Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      // THAY ĐỔI Ở ĐÂY: Trỏ vào HomeScreen
      home: const HomeScreen(),
    );
  }
}
