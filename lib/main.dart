import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/config/app_theme.dart';
import 'app/config/app_constants.dart';
import 'app/features/splash/splash_screen.dart';
import 'app/features/auth/providers/auth_provider.dart';
import 'app/features/auth/login_page.dart';
import 'app/features/screens/root/root_navigation.dart';
import 'app/config/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      key: ValueKey(authState.status),
      title: MyAppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: MyAppTheme.lightTheme,
      darkTheme: MyAppTheme.darkTheme,
      themeMode: themeMode,
      home: _getHome(authState.status),
    );
  }

  Widget _getHome(AuthStatus status) {
    switch (status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const SplashScreen();
      case AuthStatus.authenticated:
        return const RootNavigation();
      case AuthStatus.unauthenticated:
      default:
        // On could also return OnboardingScreen here if it's the first time
        return const LoginPage();
    }
  }
}
