import 'package:flutter/material.dart';

class AppColors {
  final Color bgStart;
  final Color bgEnd;
  final Color primary;
  final Color secondary;
  final Color correctTile;
  final Color defaultTile;
  final Color selectedTile;
  final Color textMain;
  final Color textLight;

  // Constructor
  const AppColors({
    required this.bgStart,
    required this.bgEnd,
    required this.primary,
    required this.secondary,
    required this.correctTile,
    required this.defaultTile,
    required this.selectedTile,
    required this.textMain,
    required this.textLight,
  });

  // --- 1. Theme 0: Classic (Giữ nguyên bản sắc cũ của bạn) ---
  static const AppColors classic = AppColors(
    bgStart: Color(0xFFE0EAFC),
    bgEnd: Color(0xFFCFDEF3),
    primary: Color(0xFF4A90E2),
    secondary: Color(0xFFFFB703),
    correctTile: Color(0xFF8FC93A),
    defaultTile: Colors.white,
    selectedTile: Color(0xFFE1F5FE),
    textMain: Color(0xFF2D3142),
    textLight: Colors.white,
  );

  // --- 2. Theme 1: Minimalist (Sạch sẽ, Tối giản) ---
  static const AppColors minimal = AppColors(
    bgStart: Color(0xFFF8FAFC),
    bgEnd: Color(0xFFE2E8F0),
    primary: Color(0xFF1E3A8A), // Xanh Denim
    secondary: Color(0xFFF97316), // Cam
    correctTile: Color(0xFF10B981),
    defaultTile: Colors.white,
    selectedTile: Color(0xFFDBEAFE),
    textMain: Color(0xFF0F172A),
    textLight: Colors.white,
  );

  // --- 3. Theme 2: Cyber (Không gian Công nghệ, Dark Mode) ---
  static const AppColors cyber = AppColors(
    bgStart: Color(0xFF0F172A),
    bgEnd: Color(0xFF020617),
    primary: Color(0xFF06B6D4), // Cyan Neon
    secondary: Color(0xFF8B5CF6), // Tím Cyber
    correctTile: Color(0xFF10B981),
    defaultTile: Color(0xFF1E293B), // Nền phím màu tối
    selectedTile: Color(0xFF334155),
    textMain: Color.fromARGB(255, 102, 116, 134), // Chữ trắng sáng
    textLight: Colors.white,
  );

  // --- HÀM MA THUẬT: Lấy bộ màu dựa trên Setting ---
  static AppColors getTheme(int index) {
    switch (index) {
      case 1:
        return minimal;
      case 2:
        return cyber;
      case 0:
      default:
        return classic;
    }
  }
}
