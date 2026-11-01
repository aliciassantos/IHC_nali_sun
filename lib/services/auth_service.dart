// Gerenciamento da sessão do usuário
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/user_dao.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final nome = name.trim();
    final emailLimpo = email.trim().toLowerCase();

    if (nome.length < 2) {
      throw Exception('Informe um nome válido.');
    }

    if (emailLimpo.isEmpty || password.isEmpty) {
      throw Exception('Preencha todos os campos obrigatórios.');
    }

    final existente = await UserDAO.getUserByEmail(emailLimpo);

    if (existente != null) {
      throw Exception('Este e-mail já está cadastrado.');
    }

    final usuario = await UserDAO.insertUser(
      name: nome,
      email: emailLimpo,
      password: password,
    );

    if (usuario == null) {
      throw Exception('Não foi possível realizar o cadastro.');
    }

    return usuario;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final emailLimpo = email.trim().toLowerCase();

    if (emailLimpo.isEmpty || password.isEmpty) {
      throw Exception('Informe o e-mail e a senha.');
    }

    final response = await _supabase.auth.signInWithPassword(
      email: emailLimpo,
      password: password,
    );

    final userId = response.user?.id;

    if (userId == null) {
      throw Exception('Usuário não encontrado.');
    }

    final user = await UserDAO.getUserById(userId);

    if (user == null) {
      throw Exception('Os dados do usuário não foram encontrados.');
    }

    return user;
  }

  Future<void> resetPassword({
    required String email,
    required String redirectTo,
  }) async {
    final emailLimpo = email.trim().toLowerCase();

    if (emailLimpo.isEmpty) {
      throw Exception('Informe um e-mail válido.');
    }

    await _supabase.auth.resetPasswordForEmail(
      emailLimpo,
      redirectTo: redirectTo,
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
