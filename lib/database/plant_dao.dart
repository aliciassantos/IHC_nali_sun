// Operações CRUD da tabela 'plants'
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlantDAO {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static const String _table = 'plants';

  /// Retorna o UUID do usuário autenticado.
  static String _getUserId() {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'Você precisa estar autenticado para realizar esta operação.',
      );
    }

    return user.id;
  }

  /// Cadastra uma planta para o usuário autenticado.
  static Future<Map<String, dynamic>> insertPlant({
    required String name,
    required String species,
    required int wateringFrequencyDays,
    required String luminosity,
    DateTime? lastWateredAt,
    String? imagePath,
  }) async {
    final userId = _getUserId();

    final plantData = <String, dynamic>{
      'user_id': userId,
      'name': name.trim(),
      'species': species.trim(),
      'watering_frequency_days': wateringFrequencyDays,
      'last_watered_at': lastWateredAt?.toUtc().toIso8601String(),
      'luminosity': luminosity,
      'image_path': imagePath,
    };

    try {
      final response = await _supabase
          .from(_table)
          .insert(plantData)
          .select()
          .single();

      debugPrint('Planta cadastrada: ${response['id']}');

      return response;
    } catch (e, stackTrace) {
      debugPrint('Erro ao cadastrar planta: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Lista somente as plantas associadas ao usuário autenticado.
  static Future<List<Map<String, dynamic>>> getPlantsByUser() async {
    final userId = _getUserId();

    try {
      debugPrint('========== MEU JARDIM ==========');
      debugPrint('Usuário autenticado: true');
      debugPrint('UUID: $userId');

      final response = await _supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final plantas = List<Map<String, dynamic>>.from(response);

      debugPrint('Plantas encontradas: ${plantas.length}');
      debugPrint('================================');

      return plantas;
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar plantas: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Busca uma planta pelo ID, respeitando o proprietário.
  static Future<Map<String, dynamic>?> getPlantById(
    int plantId,
  ) async {
    final userId = _getUserId();

    final response = await _supabase
        .from(_table)
        .select()
        .eq('id', plantId)
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  /// Atualiza uma planta pertencente ao usuário autenticado.
  static Future<Map<String, dynamic>> updatePlant({
    required int plantId,
    required String name,
    required String species,
    required int wateringFrequencyDays,
    required String luminosity,
    DateTime? lastWateredAt,
    String? imagePath,
  }) async {
    final userId = _getUserId();

    final plantData = <String, dynamic>{
      'name': name.trim(),
      'species': species.trim(),
      'watering_frequency_days': wateringFrequencyDays,
      'luminosity': luminosity,
      'last_watered_at': lastWateredAt?.toUtc().toIso8601String(),
      'image_path': imagePath,
    };

    final response = await _supabase
        .from(_table)
        .update(plantData)
        .eq('id', plantId)
        .eq('user_id', userId)
        .select()
        .single();

    return response;
  }

  /// Exclui uma planta pertencente ao usuário autenticado.
  static Future<void> deletePlant(int plantId) async {
    final userId = _getUserId();

    await _supabase
        .from(_table)
        .delete()
        .eq('id', plantId)
        .eq('user_id', userId);
  }
}