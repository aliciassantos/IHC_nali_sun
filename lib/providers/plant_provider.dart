// Estado das plantas, filtros e lógica de rega

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/plant_dao.dart';
import '../database/care_log_dao.dart';
import '../services/notification_service.dart';

class PlantProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _plantas = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get plantas => _plantas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ============================================================
  // CONTROLE DAS NOTIFICAÇÕES
  // ============================================================

  // Verifica se os lembretes de rega estão ativados.
  Future<bool> _lembretesEstaoAtivos() async {
    final prefs = await SharedPreferences.getInstance();

    // Por padrão, os lembretes ficam ativados.
    return prefs.getBool('nalisun_lembretes_rega') ?? true;
  }

  // Sincroniza as notificações respeitando a preferência.
  Future<void> _sincronizarNotificacoes() async {
    final ativos = await _lembretesEstaoAtivos();

    if (ativos) {
      // Atualiza os lembretes individuais das plantas.
      await NotificationService.sincronizarPlantas(_plantas);

      // Agenda o lembrete geral diário.
      await NotificationService.agendarLembreteGeral();
    } else {
      // Cancela todas as notificações agendadas.
      await NotificationService.cancelarTodas();
    }
  }

  // ============================================================
  // CARREGAMENTO DAS PLANTAS
  // ============================================================

  Future<void> carregarPlantas() async {
    try {
      await _carregarPlantasInterno();
    } catch (e) {
      _errorMessage = 'Erro ao carregar plantas: $e';
      notifyListeners();
    }
  }

  Future<void> _carregarPlantasInterno() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Busca as plantas do usuário autenticado.
      _plantas = await PlantDAO.getPlantsByUser();

      // Sincroniza as notificações de acordo com a preferência.
      await _sincronizarNotificacoes();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CADASTRO DE PLANTAS
  // ============================================================

  Future<void> cadastrarPlanta({
    required String name,
    required String species,
    required int wateringFrequencyDays,
    required String luminosity,
    DateTime? lastWateredAt,
    String? imagePath,
  }) async {
    try {
      await PlantDAO.insertPlant(
        name: name,
        species: species,
        wateringFrequencyDays: wateringFrequencyDays,
        luminosity: luminosity,
        lastWateredAt: lastWateredAt,
        imagePath: imagePath,
      );

      // Recarrega as plantas e sincroniza os lembretes.
      await _carregarPlantasInterno();
    } catch (e) {
      _errorMessage = 'Erro ao cadastrar planta: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ============================================================
  // ATUALIZAÇÃO DE PLANTAS
  // ============================================================

  Future<void> atualizarPlanta({
    required int plantId,
    required String name,
    required String species,
    required int wateringFrequencyDays,
    required String luminosity,
    DateTime? lastWateredAt,
    String? imagePath,
  }) async {
    try {
      await PlantDAO.updatePlant(
        plantId: plantId,
        name: name,
        species: species,
        wateringFrequencyDays: wateringFrequencyDays,
        luminosity: luminosity,
        lastWateredAt: lastWateredAt,
        imagePath: imagePath,
      );

      // Recarrega as plantas e atualiza os lembretes.
      await _carregarPlantasInterno();
    } catch (e) {
      _errorMessage = 'Erro ao atualizar planta: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ============================================================
  // EXCLUSÃO DE PLANTAS
  // ============================================================

  Future<void> excluirPlanta(int plantId) async {
    try {
      await PlantDAO.deletePlant(plantId);

      // Cancela os lembretes da planta excluída.
      await NotificationService.cancelarNotificacoesPlanta(plantId);

      _plantas.removeWhere(
        (planta) => int.tryParse(planta['id'].toString()) == plantId,
      );

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao excluir planta: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ============================================================
  // REGISTRO DE REGA
  // ============================================================

  Future<void> registrarRega(int plantId, {DateTime? scheduledFor}) async {
    try {
      await CareLogDAO.registrarRega(
        plantId: plantId,
        scheduledFor: scheduledFor ?? DateTime.now(),
      );

      await _carregarPlantasInterno();
    } catch (e) {
      _errorMessage = 'Erro ao registrar rega: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ============================================================
  // BUSCA DE PLANTAS
  // ============================================================

  Map<String, dynamic>? buscarPlanta(int plantId) {
    try {
      return _plantas.firstWhere(
        (planta) => int.tryParse(planta['id'].toString()) == plantId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // LIMPEZA DO ESTADO
  // ============================================================

  void limparPlantas() {
    _plantas = [];
    _errorMessage = null;
    notifyListeners();
  }
}
