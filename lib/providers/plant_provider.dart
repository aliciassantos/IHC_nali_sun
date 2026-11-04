// Estado das plantas, filtros e lógica de rega

import 'package:flutter/foundation.dart';

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
  // CARREGAMENTO DAS PLANTAS
  // ============================================================

  // Carrega as plantas e sincroniza suas notificações.
  Future<void> carregarPlantas() async {
    try {
      await _carregarPlantasInterno();
    } catch (e) {
      _errorMessage = 'Erro ao carregar plantas: $e';
      notifyListeners();
    }
  }

  // Método interno para carregar as plantas.
  // Permite que outras operações identifiquem falhas no carregamento.
  Future<void> _carregarPlantasInterno() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plantas = await PlantDAO.getPlantsByUser();

      // Atualiza os lembretes individuais das plantas.
      await NotificationService.sincronizarPlantas(_plantas);

      // Agenda também o lembrete geral diário.
      await NotificationService.agendarLembreteGeral();
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

      // Cancela os lembretes associados à planta excluída.
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

  Future<void> registrarRega(int plantId) async {
    try {
      // Registra a rega no histórico e atualiza last_watered_at.
      await CareLogDAO.registrarRega(plantId: plantId);

      // Recalcula os próximos lembretes com base na nova data.
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

  // Limpa os dados carregados na memória.
  // O cancelamento das notificações da conta será coordenado
  // pelo fluxo de logout/autenticação.
  void limparPlantas() {
    _plantas = [];
    _errorMessage = null;
    notifyListeners();
  }
}