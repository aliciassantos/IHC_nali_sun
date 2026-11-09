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
        .select(
          'id, performed_at, scheduled_for, plant_id, care_type',
        )
        .inFilter('plant_id', plantIds)
        .order('performed_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Registra uma rega, separando a data prevista da data realizada.
  static Future<void> registrarRega({
    required int plantId,
    required DateTime scheduledFor,
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

    // Data e horário reais da execução.
    final agora = DateTime.now();

    // Formata a data prevista sem conversão de fuso horário.
    final dataPrevista =
        '${scheduledFor.year.toString().padLeft(4, '0')}-'
        '${scheduledFor.month.toString().padLeft(2, '0')}-'
        '${scheduledFor.day.toString().padLeft(2, '0')}';

    // Mantém as duas datas no histórico.
    await _supabase.from('care_logs').insert({
      'plant_id': plantId,
      'care_type': 'watering',
      'scheduled_for': dataPrevista,
      'performed_at': agora.toUtc().toIso8601String(),
    });

    // A última rega da planta corresponde à execução real.
    await _supabase
        .from('plants')
        .update({
          'last_watered_at': agora.toUtc().toIso8601String(),
        })
        .eq('id', plantId)
        .eq('user_id', user.id);
  }
}