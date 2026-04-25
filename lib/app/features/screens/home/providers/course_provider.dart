import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/course.dart';
import '../../../../services/course_service.dart';

final courseServiceProvider = Provider<CourseService>((ref) {
  return CourseService();
});

// Fetch all courses
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final service = ref.watch(courseServiceProvider);
  return await service.getCourses();
});

// Fetch filtered courses
final filteredCoursesProvider = FutureProvider.family<List<Course>, ({String search, int? categoryId})>((ref, arg) async {
  final service = ref.watch(courseServiceProvider);
  return await service.getCourses(
    search: arg.search,
    categoryId: arg.categoryId,
  );
});

// Fetch specific course details
final courseDetailsProvider = FutureProvider.family<Course?, int>((ref, courseId) async {
  final service = ref.watch(courseServiceProvider);
  return await service.getCourse(courseId);
});
