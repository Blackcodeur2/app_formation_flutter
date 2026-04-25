import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/course.dart';
import '../../../../services/api/api_client.dart';
import '../../../../services/api/api_constants.dart';
import 'course_provider.dart';

// Service to fetch user-specific data (me)
class UserCoursesService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Course>> getMyCourses() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.me);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['courses'];
        return data.map((json) => Course.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching my courses: $e');
      return [];
    }
  }
}

final userCoursesServiceProvider = Provider((ref) => UserCoursesService());

// Using Notifier instead of StateNotifier for better compatibility
final myCoursesProvider = NotifierProvider<MyCoursesNotifier, AsyncValue<List<Course>>>(() {
  return MyCoursesNotifier();
});

class MyCoursesNotifier extends Notifier<AsyncValue<List<Course>>> {
  @override
  AsyncValue<List<Course>> build() {
    // We can't await here, so we return loading and start fetch
    _fetchCourses();
    return const AsyncValue.loading();
  }

  Future<void> _fetchCourses() async {
    final service = ref.read(userCoursesServiceProvider);
    try {
      final courses = await service.getMyCourses();
      state = AsyncValue.data(courses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _fetchCourses();
  }

  void addCourse(Course course) {
    state.whenData((courses) {
      if (!courses.any((c) => c.id == course.id)) {
        state = AsyncValue.data([...courses, course]);
      }
    });
  }
}
