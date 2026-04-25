import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart';
import 'api/api_client.dart';
import 'api/api_constants.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Login
  Future<User?> login(String login, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {
          'login': login,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        // Save token
        await _storage.write(key: 'auth_token', value: response.data['access_token']);
        return User.fromJson(response.data['user']);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Register
  Future<User?> register({
    required String nom,
    required String prenom,
    required String username,
    required String email,
    required String password,
    required String sexe,
    required String telephone,
    required String dateNaissance,
    required String niveauEtude,
    required String niveauScolaire,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {
          'nom': nom,
          'prenom': prenom,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'sexe': sexe,
          'telephone': telephone,
          'date_naissance': dateNaissance,
          'niveau_etude': niveauEtude,
          'niveau_scolaire': niveauScolaire,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['access_token'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['access_token']);
        return User.fromJson(response.data['user']);
      }
      return null;
    } on DioException catch (e) {
      print('Register Dio error: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  // Get current authenticated user
  Future<User?> getMe() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return null;

      final response = await _apiClient.dio.get(ApiConstants.me);
      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      }
      return null;
    } catch (e) {
      print('Get me error: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiConstants.logout);
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Always delete token locally
      await _storage.delete(key: 'auth_token');
    }
  }
  // Update Profile
  Future<User?> updateProfile({
    required String nom,
    required String prenom,
    required String telephone,
    required String bio,
    XFile? avatar,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'bio': bio,
      };

      if (avatar != null) {
        if (kIsWeb) {
          // On Web, we must use fromBytes as fromFile relies on dart:io
          final bytes = await avatar.readAsBytes();
          data['avatar'] = MultipartFile.fromBytes(
            bytes,
            filename: avatar.name,
          );
        } else {
          // On Mobile, fromFile is fine
          data['avatar'] = await MultipartFile.fromFile(
            avatar.path,
            filename: avatar.name,
          );
        }
      }

      final formData = FormData.fromMap(data);

      final response = await _apiClient.dio.post(
        ApiConstants.profile,
        data: formData,
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      }
      return null;
    } catch (e) {
      print('Update profile error: $e');
      return null;
    }
  }
}
