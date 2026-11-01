import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserDAO {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Cadastra um usuário no Supabase Auth e registra seus dados na tabela users.
  static Future<UserModel?> insertUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final nome = name.trim();
    final emailNormalizado = email.trim().toLowerCase();

    if (nome.length < 2) {
      throw Exception('O nome deve ter pelo menos 2 caracteres.');
    }

    if (emailNormalizado.isEmpty) {
      throw Exception('Informe um e-mail válido.');
    }

    if (password.isEmpty) {
      throw Exception('A senha não pode estar vazia.');
    }

    final response = await _supabase.auth.signUp(
      email: emailNormalizado,
      password: password,
    );

    final authUser = response.user;

    if (authUser == null) {
      return null;
    }

    final userData = <String, dynamic>{
      'id': authUser.id,
      'name': nome,
      'email': emailNormalizado,
    };

    await _supabase.from('users').upsert(userData);

    return UserModel(
      id: authUser.id,
      name: nome,
      email: emailNormalizado,
      createdAt: DateTime.now(),
    );
  }

  /// Busca um usuário pelo e-mail.
  static Future<UserModel?> getUserByEmail(String email) async {
    final emailNormalizado = email.trim().toLowerCase();

    final response = await _supabase
        .from('users')
        .select()
        .eq('email', emailNormalizado)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return UserModel.fromMap(response);
  }

  /// Atualiza a senha do usuário autenticado.
  static Future<void> updatePassword(String newPassword) async {
    if (newPassword.isEmpty) {
      throw Exception('A nova senha não pode estar vazia.');
    }

    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Busca um usuário pelo UUID.
  static Future<UserModel?> getUserById(String id) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return UserModel.fromMap(response);
  }
}