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
  bool _isRecoveringPassword = false; // Estado para redefinição
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get sessionChecked => _sessionChecked;
  bool get isRecoveringPassword => _isRecoveringPassword; // Getter
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _startAuthListen();
  }

  void _startAuthListen() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
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
    } catch (_) {
      _currentUser = null;
    } finally {
      _sessionChecked = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final user = await _authService.login(email: email, password: password);

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

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      final authUser = supabase.auth.currentUser;

      // Só define o usuário atual se houver uma sessão correspondente.
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

  Future<bool> resetPassword(String email) async {
    _setLoading(true);

    try {
      await _authService.resetPassword(
        email: email,
        redirectTo: 'http://localhost:3000/#/reset-password',
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

  void clearPasswordRecoveryFlag() {
    _isRecoveringPassword = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mensagemErro(Object erro) {
    return erro.toString().replaceFirst('Exception: ', '');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
