// Dados do usuário logado
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarPath;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarPath,
    this.createdAt,
  });

  /// Converte o usuário para um mapa compatível com a tabela users.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'avatar_path': avatarPath,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
    };
  }

  // Cria um usuário a partir dos dados retornados pelo Supabase.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'].toString(),
      name: map['name'] as String,
      email: map['email'] as String,
      avatarPath: map['avatar_path'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString()).toLocal()
          : null,
    );
  }
}
