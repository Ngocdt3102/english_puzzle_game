import 'package:flutter/material.dart';

class AppColors {
  // Màu nền tảng (Gradient từ xanh dương nhạt sang tím nhạt)
  static const Color bgStart = Color(0xFFE0EAFC);
  static const Color bgEnd = Color(0xFFCFDEF3);

  // Màu chủ đạo
  static const Color primary = Color(0xFF4A90E2);
  static const Color secondary = Color(0xFFFFB703); // Vàng cam bắt mắt

  // Trạng thái ô chữ
  static const Color correctTile = Color(0xFF8FC93A); // Xanh lá mượt
  static const Color defaultTile = Colors.white;
  static const Color selectedTile = Color(
    0xFFE1F5FE,
  ); // Xanh nhạt khi đang chọn

  // Chữ
  static const Color textMain = Color(0xFF2D3142);
  static const Color textLight = Colors.white;
}
