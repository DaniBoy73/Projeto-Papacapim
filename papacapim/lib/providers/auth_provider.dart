// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../data/mock_data.dart';

/// Gerencia o estado de autenticação em memória.
/// Na Parte 2: substituir os métodos de login/register por chamadas HTTP.
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------
  /// Simula autenticação. Na Parte 2: POST /sessions
  Future<bool> login(String login, String password) async {
    _setLoading(true);
    _errorMessage = null;

    // Simula latência de rede
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final user = mockUsers.firstWhere(
        (u) => u.login == login.trim() && u.password == password,
        orElse: () => throw Exception('Usuário ou senha incorretos.'),
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Registro
  // ---------------------------------------------------------------------------
  /// Simula criação de conta. Na Parte 2: POST /users
  Future<bool> register({
    required String name,
    required String login,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Verifica se login já existe
      final exists = mockUsers.any((u) => u.login == login.trim());
      if (exists) throw Exception('Este login já está em uso.');

      final newUser = UserModel(
        id: (mockUsers.length + 1).toString(),
        name: name.trim(),
        login: login.trim(),
        password: password,
        bio: '',
        avatarUrl: null,
      );

      mockUsers.add(newUser);
      _currentUser = newUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Editar perfil
  // ---------------------------------------------------------------------------
  void updateProfile({
    String? name,
    String? bio,
    String? avatarUrl,
    String? localAvatarPath,
  }) {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name,
      bio: bio,
      avatarUrl: avatarUrl,
      localAvatarPath: localAvatarPath,
    );

    // Sincroniza na lista global (para exibição nos posts mockados)
    final idx = mockUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (idx != -1) {
      mockUsers[idx] = _currentUser!;
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
