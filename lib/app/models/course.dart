import 'category.dart';
import 'module.dart';
import 'user.dart';

class Course {
  final int id;
  final int? categoryId;
  final int instructorId;
  final String title;
  final String description;
  final double price;
  final String level; // beginner, intermediate, advanced
  final String? thumbnail;
  final DateTime? createdAt;
  
  // Relations
  final Category? category;
  final User? instructor;
  final List<Module> modules;
  final int enrollmentsCount;

  Course({
    required this.id,
    this.categoryId,
    required this.instructorId,
    required this.title,
    required this.description,
    required this.price,
    required this.level,
    this.thumbnail,
    this.createdAt,
    this.category,
    this.instructor,
    this.modules = const [],
    this.enrollmentsCount = 0,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      categoryId: json['category_id'] != null 
          ? (json['category_id'] is int ? json['category_id'] : int.parse(json['category_id'].toString()))
          : null,
      instructorId: json['instructor_id'] != null
          ? (json['instructor_id'] is int ? json['instructor_id'] : int.parse(json['instructor_id'].toString()))
          : 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      level: json['level'] ?? 'beginner',
      thumbnail: json['thumbnail'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      instructor: json['instructor'] != null ? User.fromJson(json['instructor']) : null,
      modules: json['modules'] != null 
          ? (json['modules'] as List).map((i) => Module.fromJson(i)).toList()
          : [],
      enrollmentsCount: json['enrollments_count'] != null
          ? (json['enrollments_count'] is int ? json['enrollments_count'] : int.parse(json['enrollments_count'].toString()))
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'instructor_id': instructorId,
      'title': title,
      'description': description,
      'price': price,
      'level': level,
      'thumbnail': thumbnail,
    };
  }

  // App-specific UI helpers
  String get formattedPrice => price > 0 ? '${price.toInt()} FCFA' : 'Gratuit';
  
  String get displayLevel {
    switch (level) {
      case 'Primaire': return 'Primaire';
      case 'Secondaire': return 'Secondaire';
      case 'Supérieur': return 'Supérieur';
      default: return level;
    }
  }

  int get totalDurationMinutes {
    int total = 0;
    for (var module in modules) {
      for (var lesson in module.lessons) {
        if (lesson.duration != null) {
          total += lesson.duration!;
        }
      }
    }
    return total;
  }

  String get formattedDuration {
    final hours = totalDurationMinutes ~/ 60;
    final minutes = totalDurationMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  double get completionPercentage {
    final allLessons = modules.expand((m) => m.lessons).toList();
    if (allLessons.isEmpty) return 0.0;
    
    final completedLessons = allLessons.where((l) => l.isCompleted).length;
    return completedLessons / allLessons.length;
  }
  
  bool get isCompleted => completionPercentage >= 1.0;
}
