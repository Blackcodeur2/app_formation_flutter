import 'package:dio/dio.dart';
import '../models/course.dart';
import 'api/api_client.dart';
import 'api/api_constants.dart';

class CourseService {
  final ApiClient _apiClient = ApiClient();

  // Get all courses (with optional filters)
  Future<List<Course>> getCourses({String? search, int? categoryId, String? level}) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (search != null) queryParameters['search'] = search;
      if (categoryId != null) queryParameters['category_id'] = categoryId;
      if (level != null) queryParameters['level'] = level;

      final response = await _apiClient.dio.get(
        ApiConstants.courses,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final dynamic rawData = response.data;
        List<dynamic> list;
        
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map && rawData.containsKey('data')) {
          list = rawData['data'];
        } else {
          list = [];
        }
        
        return list.map((json) => Course.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  // Get single course details (with modules and lessons)
  Future<Course?> getCourse(int id) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.courses}/$id');
      if (response.statusCode == 200) {
        return Course.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching course $id: $e');
      return null;
    }
  }

  // Enroll in a course
  Future<bool> enrollInCourse(int id) async {
    try {
      final response = await _apiClient.dio.post('${ApiConstants.courses}/$id/enroll');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error enrolling in course $id: $e');
      return false;
    }
  }

  // Update lesson progress
  Future<bool> updateProgress({required int lessonId, bool completed = true, double progressPercentage = 100}) async {
    try {
      final response = await _apiClient.dio.post('/progress/update', data: {
        'lesson_id': lessonId,
        'completed': completed,
        'progress_percentage': progressPercentage,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating progress for lesson $lessonId: $e');
      return false;
    }
  }
}
