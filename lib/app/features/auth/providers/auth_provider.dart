import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

// État de l'authentification
enum AuthStatus { initial, unauthenticated, authenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    // checkAuthStatus() est appelé par le SplashScreen une fois
    // que le serveur backend a été découvert et l'URL configurée.
    return AuthState();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    final user = await _authService.getMe();
    
    if (user != null) {
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String login, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    final user = await _authService.login(login, password);
    if (user != null) {
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated, 
        errorMessage: 'Email ou mot de passe incorrect'
      );
      return false;
    }
  }

  Future<bool> register({
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
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    final user = await _authService.register(
      nom: nom,
      prenom: prenom,
      username: username,
      email: email,
      password: password,
      sexe: sexe,
      telephone: telephone,
      dateNaissance: dateNaissance,
      niveauEtude: niveauEtude,
      niveauScolaire: niveauScolaire,
    );
    
    if (user != null) {
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated, 
        errorMessage: 'Erreur lors de l\'inscription'
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authService.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }

  Future<bool> updateProfile({
    required String nom,
    required String prenom,
    required String telephone,
    required String bio,
    XFile? avatar,
  }) async {
    final updatedUser = await _authService.updateProfile(
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      bio: bio,
      avatar: avatar,
    );

    if (updatedUser != null) {
      state = state.copyWith(user: updatedUser);
      return true;
    }
    return false;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
