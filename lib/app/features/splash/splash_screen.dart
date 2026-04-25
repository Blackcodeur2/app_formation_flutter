import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_constants.dart';
import '../../config/app_colors.dart';
import '../../services/api/api_client.dart';
import '../../services/api/api_constants.dart';
import '../../services/api/network_discovery_service.dart';
import '../auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _statusMessage = 'Connexion au serveur...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _discoverAndConnect();
  }

  void _showManualConfigDialog() {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Configuration manuelle du serveur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Entrez l\'URL complète de votre serveur API Laravel :',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: 'http://192.168.1.100:8000/api',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final url = urlController.text.trim();
                if (url.isNotEmpty) {
                  _configureManualUrl(url);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Configurer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _configureManualUrl(String url) async {
    setState(() {
      _statusMessage = 'Configuration manuelle...';
      _hasError = false;
    });

    try {
      // Vérifier que l'URL est accessible
      final isReachable = await NetworkDiscoveryService.testUrl(url);
      if (!isReachable) {
        throw Exception('URL non accessible. Vérifiez l\'adresse et réessayez.');
      }

      // Configurer l'URL
      ApiConstants.setBaseUrl(url);
      ApiClient().updateBaseUrl(url);

      if (!mounted) return;
      setState(() {
        _statusMessage = 'Serveur configuré ✓';
      });

      // Vérifier le statut d'authentification
      await ref.read(authProvider.notifier).checkAuthStatus();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _statusMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MyAppColors.primary,
              Color(0xFF1E3A8A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Cercle décoratif en arrière-plan
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Contenu principal centré
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.school_rounded,
                          size: 60,
                          color: MyAppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    MyAppConstants.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Éduquer. Inspirer. Réussir.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.84),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bas de l'écran : statut + spinner ou bouton réessayer
            Positioned(
              bottom: 50,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  if (_hasError) ...[
                    // Icône d'erreur
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white70,
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    // Message d'erreur
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Boutons
                    Column(
                      children: [
                        SizedBox(
                          width: 180,
                          child: ElevatedButton.icon(
                            onPressed: _discoverAndConnect,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Réessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: MyAppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 180,
                          child: OutlinedButton.icon(
                            onPressed: _showManualConfigDialog,
                            icon: const Icon(Icons.settings_rounded, size: 18),
                            label: const Text('Configuration manuelle'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white70),
                              foregroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Spinner de chargement
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Message de statut
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

