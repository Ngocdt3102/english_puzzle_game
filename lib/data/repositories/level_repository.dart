import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/level_model.dart';

class LevelRepository {
  // Biến tạm để lưu trữ danh sách các màn chơi sau khi load từ JSON
  List<LevelModel> _allLevels = [];

  /// Hàm khởi tạo dữ liệu từ file batch_0.json
  /// Ngọc nên gọi hàm này một lần khi ứng dụng bắt đầu hoặc khi vào màn hình Game
  Future<void> init() async {
    try {
      // 1. Đọc tệp JSON từ thư mục assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/batch_0.json',
      );

      // 2. Giải mã chuỗi JSON thành List động
      final List<dynamic> jsonResponse = json.decode(jsonString);

      // 3. Map từng phần tử trong List sang đối tượng LevelModel
      _allLevels = jsonResponse
          .map((data) => LevelModel.fromJson(data))
          .toList();

      print("Đã nạp thành công ${_allLevels.length} màn chơi từ batch_0.json");
    } catch (e) {
      print("Lỗi khi nạp dữ liệu: $e");
      // Ngọc có thể ném lỗi (throw) để UI xử lý thông báo cho người dùng
      rethrow;
    }
  }

  /// Hàm lấy dữ liệu của một màn chơi cụ thể theo levelId
  // Thêm dấu ? để cho phép trả về null
  LevelModel? getLevelById(int id) {
    try {
      return _allLevels.firstWhere((level) => level.levelId == id);
    } catch (e) {
      // Nếu không tìm thấy, trả về null để Provider xử lý nhẹ nhàng
      return null;
    }
  }

  /// Trả về tổng số màn chơi hiện có
  int get totalLevels => _allLevels.length;

  /// Kiểm tra xem đã nạp dữ liệu chưa
  bool get isInitialized => _allLevels.isNotEmpty;
}
