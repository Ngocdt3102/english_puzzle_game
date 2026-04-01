import 'package:flutter/material.dart';

class TopicModel {
  final String id;
  final String title;
  final IconData icon; // Đã đổi sang kiểu IconData
  final String fileName;
  final int totalLevels;
  final List<int> levelIds;

  TopicModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.fileName,
    required this.totalLevels,
    required this.levelIds,
  });
}

// DANH SÁCH DỮ LIỆU ĐÃ CẬP NHẬT ICON
final List<TopicModel> appTopics = [
  TopicModel(
    id: 'FOOD_01',
    title: 'Food & Drinks',
    icon: Icons.fastfood_rounded, // Sử dụng hệ thống Icon
    fileName: 'topic_food',
    totalLevels: 50,
    levelIds: List.generate(50, (index) => index + 1),
  ),
  TopicModel(
    id: 'ANIMAL_01',
    title: 'Animals',
    icon: Icons.pets_rounded,
    fileName: 'topic_animal',
    totalLevels: 50,
    levelIds: List.generate(50, (index) => index + 1),
  ),
  TopicModel(
    id: 'WEATHER_NATURE_01',
    title: 'Weather & Nature',
    icon: Icons.wb_sunny_rounded,
    fileName: 'topic_weather',
    totalLevels: 50,
    levelIds: List.generate(50, (index) => index + 1),
  ),
  TopicModel(
    id: 'TRAVEL_01',
    title: 'Travel & Transport',
    icon: Icons.flight_takeoff_rounded,
    fileName: 'topic_travel',
    totalLevels: 50,
    levelIds: List.generate(50, (index) => index + 1),
  ),
  TopicModel(
    id: 'TECH_01',
    title: 'Technology',
    icon: Icons.biotech_rounded,
    fileName: 'topic_tech',
    totalLevels: 50,
    levelIds: List.generate(50, (index) => index + 1),
  ),
  TopicModel(
    id: 'HEALTH_01',
    title: 'Health & Body',
    icon: Icons.favorite_rounded,
    fileName: 'topic_health',
    totalLevels: 50,
    levelIds: List.generate(50, (index) => index + 1),
  ),
];
