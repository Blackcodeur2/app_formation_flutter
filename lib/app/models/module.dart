import 'lesson.dart';

class Module {
  final int id;
  final String title;
  final int orderIndex;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.title,
    required this.orderIndex,
    this.lessons = const [],
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      orderIndex: json['order_index'] != null
          ? (json['order_index'] is int ? json['order_index'] : int.parse(json['order_index'].toString()))
          : 1,
      lessons: json['lessons'] != null
          ? (json['lessons'] as List).map((i) => Lesson.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'order_index': orderIndex,
      'lessons': lessons.map((e) => e.toJson()).toList(),
    };
  }
}
