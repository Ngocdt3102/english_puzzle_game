import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/level_model.dart';

class LevelRepository {
  // 1. VŨ KHÍ BÍ MẬT: BỘ NHỚ ĐỆM (CACHE)
  // Lưu trữ các chủ đề đã tải. Key là tên file (vd: 'topic_food').
  // Giúp app không phải đọc lại file tĩnh nhiều lần, tiết kiệm CPU và Pin.
  final Map<String, List<LevelModel>> _levelsCache = {};

  // Danh sách màn chơi của chủ đề đang được chọn hiện tại
  List<LevelModel> _currentTopicLevels = [];

  // Lưu lại tên chủ đề đang chơi để UI biết (tùy chọn)
  String currentTopicName = "";

  /// Hàm nạp dữ liệu động theo tên file.
  /// Ngọc gọi hàm này khi người dùng bấm vào một Thẻ chủ đề ở màn hình Home.
  /// Ví dụ: await repository.loadTopic('topic_food');
  Future<void> loadTopic(String fileName) async {
    try {
      // 1. Kiểm tra Cache: Nếu đã nạp rồi thì lấy ra dùng luôn, bỏ qua bước đọc file
      if (_levelsCache.containsKey(fileName)) {
        _currentTopicLevels = _levelsCache[fileName]!;
        print("⚡ Đã lấy dữ liệu '$fileName' từ Cache siêu tốc!");
        return;
      }

      // 2. Nếu chưa có trong Cache, tiến hành đọc file JSON
      final String jsonString = await rootBundle.loadString(
        'assets/data/$fileName.json',
      );

      // 3. Giải mã JSON
      // LƯU Ý QUAN TRỌNG: Cấu trúc V2 bắt đầu bằng Object {}, nên cast sang Map
      final Map<String, dynamic> jsonResponse = json.decode(jsonString);

      // Lấy tên chủ đề để hiển thị lên UI (Appbar)
      currentTopicName = jsonResponse['topic_name'] ?? "Chủ đề";

      // Trích xuất mảng "levels" từ bên trong Object
      final List<dynamic> levelsData = jsonResponse['levels'];

      // 4. Map dữ liệu thô sang Object Dart
      final List<LevelModel> parsedLevels = levelsData
          .map((data) => LevelModel.fromJson(data))
          .toList();

      // 5. Lưu vào Cache để dùng cho lần sau và cập nhật danh sách hiện tại
      _levelsCache[fileName] = parsedLevels;
      _currentTopicLevels = parsedLevels;

      print(
        "✅ Đã nạp thành công ${_currentTopicLevels.length} màn chơi từ $fileName.json",
      );
    } catch (e) {
      print("❌ Lỗi khi nạp dữ liệu chủ đề $fileName: $e");
      // Ném lỗi để UI (Provider) có thể show SnackBar báo lỗi cho người dùng
      rethrow;
    }
  }

  /// Hàm lấy dữ liệu của một màn chơi cụ thể theo levelId trong CHỦ ĐỀ HIỆN TẠI
  LevelModel? getLevelById(int id) {
    try {
      return _currentTopicLevels.firstWhere((level) => level.levelId == id);
    } catch (e) {
      return null;
    }
  }

  /// Trả về tổng số màn chơi của chủ đề hiện tại
  int get totalLevels => _currentTopicLevels.length;

  /// Trả về danh sách toàn bộ level hiện tại (Phục vụ cho màn hình Chọn Màn - Level Selection)
  List<LevelModel> get currentLevels => _currentTopicLevels;

  /// Kiểm tra xem Repository đã sẵn sàng chưa
  bool get isInitialized => _currentTopicLevels.isNotEmpty;
}
