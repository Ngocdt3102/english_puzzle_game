import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();

  // Cấu hình giọng đọc ban đầu
  static Future<void> init() async {
    await _flutterTts.setLanguage("en-US"); // Giọng tiếng Anh Mỹ
    await _flutterTts.setSpeechRate(0.45); // Tốc độ đọc vừa phải để dễ nghe
    await _flutterTts.setVolume(1.0); // Âm lượng tối đa
    await _flutterTts.setPitch(1.0); // Độ trầm bổng tiêu chuẩn
  }

  // Hàm gọi ra để đọc một từ
  static Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }
}
