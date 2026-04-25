class ApiConstants {
  // URL de base définie dynamiquement au démarrage par NetworkDiscoveryService
  static String _baseUrl = '';

  static String get baseUrl => _baseUrl;

  /// Appelé par NetworkDiscoveryService une fois le serveur détecté.
  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String profile = '/me/profile';

  // Course endpoints
  static const String courses = '/courses';
  static const String categories = '/categories';
}
