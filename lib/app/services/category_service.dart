import 'package:dio/dio.dart';
import '../models/category.dart';
import 'api/api_client.dart';
import 'api/api_constants.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.categories);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
}
