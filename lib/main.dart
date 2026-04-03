import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/tts_service.dart';
import 'data/repositories/level_repository.dart';
import 'logic/game_provider.dart';
import 'logic/practice_provider.dart';
import 'logic/settings_provider.dart';
import 'ui/screens/dictionary_screen.dart';
// Đừng quên import màn hình Game của bạn vào đây nhé!
import 'ui/screens/game_screen.dart';
// Import các màn hình của bạn
import 'ui/screens/home_screen.dart';
import 'ui/screens/level_selection_screen.dart';
import 'ui/screens/topic_selection_screen.dart';

void main() async {
  // Đảm bảo Flutter đã sẵn sàng để gọi các dịch vụ hệ thống (SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo dịch vụ giọng đọc (TTS)
  await TTSService.init();

  // 2. Khởi tạo Repository (V2)
  // LƯU Ý: Không còn gọi levelRepository.init() nữa!
  // Repository hiện tại chỉ là một cái vỏ rỗng, nó sẽ tự động nạp JSON
  // khi người chơi bấm chọn chủ đề ở TopicSelectionScreen.
  final levelRepository = LevelRepository();

  // 3. Khởi tạo GameProvider (Xử lý logic game)
  final gameProvider = GameProvider(levelRepository);
  // Nạp lại tiến độ học (số level đã qua, từ vựng đã mở khóa) từ bộ nhớ máy
  await gameProvider.initPrefs();

  // 4. Khởi tạo SettingsProvider (Xử lý Theme, Âm thanh, Rung)
  final settingsProvider = SettingsProvider();
  // Nếu settingsProvider của bạn có hàm load cài đặt thì gọi ở đây, ví dụ:
  // await settingsProvider.initPrefs();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gameProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => PracticeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Nếu bạn muốn MaterialApp đồng bộ màu nền cơ bản với Theme Tắc kè hoa
    // bạn có thể lấy settings ở đây: final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Vocab Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        // Nếu app bạn có font chữ xịn (như Nunito hay Poppins), khai báo ở đây:
        // fontFamily: 'Nunito',
      ),

      // Màn hình khởi động mặc định
      home: const HomeScreen(),

      // --- ĐỊNH NGHĨA BỘ ĐƯỜNG DẪN (ROUTES) CHO V2 ---
      // Giúp việc chuyển trang gọn gàng hơn thay vì dùng MaterialPageRoute liên tục
      routes: {
        '/topic_selection': (context) => const TopicSelectionScreen(),
        '/dictionary': (context) => const DictionaryScreen(),
        '/level_selection': (context) => const LevelSelectionScreen(),
        // Nhớ bỏ comment dòng dưới đây và gắn màn hình Game của bạn vào nhé!
        '/game_screen': (context) => const GameScreen(),
      },
    );
  }
}
