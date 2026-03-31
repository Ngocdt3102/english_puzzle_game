// Đường dẫn: lib/data/models/topic_model.dart

class TopicModel {
  final String id;
  final String title;
  final String icon;
  final String fileName; // Tên file JSON (không có đuôi .json)
  final int totalLevels;
  final List<int> levelIds; // MỚI: Danh sách ID các level thuộc chủ đề này

  TopicModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.fileName,
    required this.totalLevels,
    required this.levelIds,
  });
}

// DANH SÁCH DỮ LIỆU THẬT CỦA APP
// Sau này mỗi lần Ngọc nhờ AI làm thêm 1 file JSON mới, bạn chỉ cần vào đây thêm 1 block mới là xong.
final List<TopicModel> appTopics = [
  TopicModel(
    id: 'FOOD_01',
    title: 'Food & Drinks',
    icon: '🍔',
    fileName: 'topic_food', // Sẽ gọi file assets/data/topic_food.json
    totalLevels: 50,
    levelIds: List.generate(50, (index) => index + 1),
  ),
  TopicModel(
    id: 'TRAVEL_01',
    title: 'Travel & Airport',
    icon: '✈️',
    fileName: 'topic_travel',
    totalLevels: 5,
    // Giả sử chủ đề Travel chứa các level từ 6 đến 10
    levelIds: [6, 7, 8, 9, 10],
  ),
  TopicModel(
    id: 'TECH_01',
    title: 'Technology',
    icon: '💻',
    fileName: 'topic_tech',
    totalLevels: 5,
    levelIds: [11, 12, 13, 14, 15],
  ),
  TopicModel(
    id: 'HEALTH_01',
    title: 'Health & Body',
    icon: '❤️',
    fileName: 'topic_health',
    totalLevels: 5,
    levelIds: [16, 17, 18, 19, 20],
  ),
];
