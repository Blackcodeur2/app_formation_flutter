class Lesson {
  final int id;
  final int moduleId;
  final String title;
  final String type; // video, text, quiz
  final String content;
  final int? duration;
  final int orderIndex;
  
  // App-specific UI state
  final bool isCompleted;
  final bool isLocked;

  Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.type,
    required this.content,
    this.duration,
    required this.orderIndex,
    this.isCompleted = false,
    this.isLocked = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      moduleId: json['module_id'] != null
          ? (json['module_id'] is int ? json['module_id'] : int.parse(json['module_id'].toString()))
          : 0,
      title: json['title'] ?? '',
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
      duration: json['duration'] != null
          ? (json['duration'] is int ? json['duration'] : int.parse(json['duration'].toString()))
          : null,
      orderIndex: json['order_index'] != null
          ? (json['order_index'] is int ? json['order_index'] : int.parse(json['order_index'].toString()))
          : 1,
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
      isLocked: false, // We'll manage locks via enrollment logic later
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'title': title,
      'type': type,
      'content': content,
      'duration': duration,
      'order_index': orderIndex,
      'is_completed': isCompleted,
    };
  }
}
