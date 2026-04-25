import 'dart:async';
import 'package:http/http.dart' as http;

class NetworkDiscoveryService {
  /// Liste de toutes les URLs candidates du serveur backend
  static const List<String> _candidateUrls = [
    'http://192.168.100.39:8000/api',
    'http://192.168.1.27:8000/api',
    'http://192.168.1.144:8000/api',
  ];

  static const Duration _timeout = Duration(seconds: 5);
  static Future<String> discoverServer() async {
    final completer = Completer<String>();
    int failedCount = 0;
    final total = _candidateUrls.length;

    for (final url in _candidateUrls) {
      _tryUrl(url).then((reachable) {
        if (reachable && !completer.isCompleted) {
          completer.complete(url);
        } else if (!reachable) {
          failedCount++;
          if (failedCount == total && !completer.isCompleted) {
            completer.completeError(
              Exception(
                'Aucun serveur  joignable.\n'
                'Vérifiez que le serveur est démarré et que vous êtes\n'
                'connecté au bon réseau Wi-Fi.',
              ),
            );
          }
        }
      }).catchError((_) {
        failedCount++;
        if (failedCount == total && !completer.isCompleted) {
          completer.completeError(
            Exception(
              'Aucun serveur backend joignable.\n'
              'Vérifiez que le serveur est démarré et que vous êtes\n'
              'connecté au bon réseau Wi-Fi.',
            ),
          );
        }
      });
    }

    return completer.future;
  }

  /// Effectue un GET sur [url] et retourne true si le serveur répond.
  static Future<bool> _tryUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      // On considère que le serveur est joignable si on reçoit une réponse
      // (même un 401 ou 404 signifie que le serveur tourne)
      return response.statusCode > 0;
    } catch (_) {
      return false;
    }
  }

  /// Teste une URL spécifique et retourne true si elle est accessible.
  static Future<bool> testUrl(String url) async {
    return _tryUrl(url);
  }
}
