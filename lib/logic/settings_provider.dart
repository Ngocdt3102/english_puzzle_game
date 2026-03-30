import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isSoundEnabled = true;
  bool _isHapticEnabled = true;
  int _themeIndex = 0; // 0: Mặc định, 1: Tối giản, 2: Dark/Tech

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isHapticEnabled => _isHapticEnabled;
  int get themeIndex => _themeIndex;

  SettingsProvider() {
    _loadSettings();
  }

  // Tải cài đặt cũ từ bộ nhớ máy khi mở App
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
    _isHapticEnabled = prefs.getBool('isHapticEnabled') ?? true;
    _themeIndex = prefs.getInt('themeIndex') ?? 0;
    notifyListeners();
  }

  // Bật/tắt Âm thanh
  Future<void> toggleSound(bool value) async {
    _isSoundEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundEnabled', value);
  }

  // Bật/tắt Rung
  Future<void> toggleHaptic(bool value) async {
    _isHapticEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHapticEnabled', value);
  }

  // Đổi Theme
  Future<void> changeTheme(int index) async {
    _themeIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeIndex', index);
  }
}
