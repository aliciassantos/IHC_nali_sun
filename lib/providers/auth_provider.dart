// Estado da autenticação do usuário

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../database/user_dao.dart';

SupabaseClient get supabase => Supabase.instance.client;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  StreamSubscription<AuthState>? _authSubscription;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _sessionChecked = false;
  bool _isRecoveringPassword = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get sessionChecked => _sessionChecked;
  bool get isRecoveringPassword => _isRecoveringPassword;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _startAuthListen();
  }

  // Escuta alterações na autenticação do Supabase
  void _startAuthListen() {
    _authSubscription =
        supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        _isRecoveringPassword = true;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // Restaura a sessão do usuário
  Future<void> restoreSession() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        _currentUser = await UserDAO.getUserById(userId);

        if (_currentUser == null) {
          await supabase.auth.signOut();
        }
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _currentUser = null;
    } finally {
      _sessionChecked = true;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );

      _currentUser = user;
      _errorMessage = null;
      _sessionChecked = true;

      return true;
    } catch (e) {
      _errorMessage = _mensagemErro(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cadastro
  Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    _setLoading(true);

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      final authUser = supabase.auth.currentUser;

      // Define o usuário atual somente se houver uma sessão correspondente.
      if (authUser != null && authUser.id == user.id) {
        _currentUser = user;
      } else {
        _currentUser = null;
      }

      _errorMessage = null;
      _sessionChecked = true;

      return true;
    } catch (e) {
      _errorMessage = _mensagemErro(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Recuperação de senha
  Future<bool> resetPassword(String email) async {
    _setLoading(true);

    try {
      await _authService.resetPassword(
        email: email,
        redirectTo:
            'http://localhost:3000/#/reset-password',
      );

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _mensagemErro(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();

      _currentUser = null;
      _errorMessage = null;
      _isRecoveringPassword = false;
    } finally {
      notifyListeners();
    }
  }

  // Limpa o estado de recuperação de senha
  void clearPasswordRecoveryFlag() {
    _isRecoveringPassword = false;
    notifyListeners();
  }

  // Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Atualiza o nome do usuário
  Future<void> updateName(String newName) async {
    final usuario = _currentUser;

    if (usuario == null) {
      throw Exception('Nenhum usuário está conectado.');
    }

    try {
      _setLoading(true);

      final usuarioAtualizado = await UserDAO.updateName(
        userId: usuario.id,
        newName: newName,
      );

      // Atualiza o usuário armazenado no Provider.
      _currentUser = usuarioAtualizado;
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = _mensagemErro(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Atualiza a foto do usuário
  Future<void> updateAvatar(String? avatarPath) async {
    final usuario = _currentUser;

    if (usuario == null) {
      throw Exception('Nenhum usuário está conectado.');
    }

    try {
      _setLoading(true);

      final usuarioAtualizado = await UserDAO.updateAvatar(
        userId: usuario.id,
        avatarPath: avatarPath,
      );

      // Atualiza o usuário armazenado no Provider.
      _currentUser = usuarioAtualizado;
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = _mensagemErro(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Converte erros em mensagens mais simples
  String _mensagemErro(Object erro) {
    return erro.toString().replaceFirst('Exception: ', '');
  }

  // Controla o estado de carregamento
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}