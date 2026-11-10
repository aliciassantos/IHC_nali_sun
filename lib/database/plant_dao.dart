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

  // ============================================================
  // UPLOAD DE FOTO
  // ============================================================

  static Future<String?> uploadFotoSupabase(Uint8List bytes) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final path = 'plants/$fileName';

      await _supabase.storage
          .from('plant-photos')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final publicUrl = _supabase.storage
          .from('plant-photos')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      debugPrint('Erro no upload da foto: $e');
      return null;
    }
  }

  // ============================================================
  // CADASTRO DE PLANTAS
  // ============================================================

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

  // ============================================================
  // LISTAGEM DE PLANTAS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getPlantsByUser() async {
    final userId = _getUserId();

    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final plantas = List<Map<String, dynamic>>.from(response);

      debugPrint('========== MEU JARDIM ==========');
      debugPrint('Usuário autenticado: true');
      debugPrint('UUID: $userId');
      debugPrint('Plantas encontradas: ${plantas.length}');
      debugPrint('================================');

      return plantas;
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar plantas: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // BUSCA DE UMA PLANTA
  // ============================================================

  static Future<Map<String, dynamic>?> getPlantById(int plantId) async {
    final userId = _getUserId();

    final response = await _supabase
        .from(_table)
        .select()
        .eq('id', plantId)
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  // ============================================================
  // ATUALIZAÇÃO DE PLANTAS
  // ============================================================

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

    // Atualiza os campos editáveis.
    final plantData = <String, dynamic>{
      'name': name.trim(),
      'species': species.trim(),
      'watering_frequency_days': wateringFrequencyDays,
      'luminosity': luminosity,
    };

    // Só altera a última rega quando uma data for informada.
    if (lastWateredAt != null) {
      plantData['last_watered_at'] = lastWateredAt.toUtc().toIso8601String();
    }

    // Só altera a foto quando um novo caminho for informado.
    if (imagePath != null) {
      plantData['image_path'] = imagePath;
    }

    final response = await _supabase
        .from(_table)
        .update(plantData)
        .eq('id', plantId)
        .eq('user_id', userId)
        .select()
        .single();

    return response;
  }

  // ============================================================
  // EXCLUSÃO DE PLANTAS
  // ============================================================

  static Future<void> deletePlant(int plantId) async {
    final userId = _getUserId();

    await _supabase
        .from(_table)
        .delete()
        .eq('id', plantId)
        .eq('user_id', userId);
  }

  // ============================================================
  // DETALHES DA PLANTA
  // ============================================================

  static Future<int> buscarRegasDoMes(String plantId) async {
    final inicioDoMes = DateTime(DateTime.now().year, DateTime.now().month, 1);

    try {
      final response = await _supabase
          .from('watering_history')
          .select()
          .eq('plant_id', int.parse(plantId))
          .gte('watering_date', inicioDoMes.toIso8601String());

      return (response as List).length;
    } catch (e) {
      debugPrint('Erro ao buscar regas do mês: $e');
      return 0;
    }
  }
}
