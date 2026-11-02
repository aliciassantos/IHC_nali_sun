// Operações CRUD da tabela 'care_logs'
// Histórico de regas e adubações
import 'package:supabase_flutter/supabase_flutter.dart';

class CareLogDAO {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Retorna os registros de cuidados das plantas do usuário autenticado.
  static Future<List<Map<String, dynamic>>> getCareLogsByUser({
    required List<int> plantIds,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Você precisa estar autenticado.');
    }

    if (plantIds.isEmpty) {
      return [];
    }

    final response = await _supabase
        .from('care_logs')
        .select('id, performed_at, plant_id, care_type')
        .inFilter('plant_id', plantIds)
        .order('performed_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Registra uma rega no histórico.
  ///
  /// Primeiro verifica se a planta pertence ao usuário autenticado.
  /// A política RLS de care_logs também deve validar essa propriedade.
  static Future<void> registrarRega({
    required int plantId,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Você precisa estar autenticado.');
    }

    final planta = await _supabase
        .from('plants')
        .select('id, user_id')
        .eq('id', plantId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (planta == null) {
      throw Exception('Planta não encontrada ou sem permissão.');
    }

    final agora = DateTime.now();

    // Registra o cuidado sem apagar os registros anteriores.
    await _supabase.from('care_logs').insert({
      'plant_id': plantId,
      'care_type': 'watering',
      'performed_at': agora.toUtc().toIso8601String(),
    });

    // Mantém a última rega sincronizada com a tabela plants.
    await _supabase
        .from('plants')
        .update({
          'last_watered_at': agora.toUtc().toIso8601String(),
        })
        .eq('id', plantId)
        .eq('user_id', user.id);
  }
}