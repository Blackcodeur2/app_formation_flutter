import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory ApiClient() {
    return _instance;
  }

  /// Met à jour la baseUrl du client Dio (appelé après découverte réseau)
  void updateBaseUrl(String url) {
    dio.options.baseUrl = url;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl, // sera mis à jour via updateBaseUrl()
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Ajout de l'intercepteur pour injecter le token Bearer
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Récupérer le token du stockage sécurisé
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Gestion basique des erreurs 401 (Non autorisé)
          if (e.response?.statusCode == 401) {
            // Optionnel: Déconnecter l'utilisateur si le token est invalide/expiré
            // await _storage.delete(key: 'auth_token');
          }
          return handler.next(e);
        },
      ),
    );
  }
}
