import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ID reservado para o lembrete geral.
  static const int _idLembreteGeral = 1;

  // Configurações do canal de notificações.
  static const String _canalId = 'nalisun_cuidados';
  static const String _canalNome = 'Cuidados com as plantas';

  static bool _inicializado = false;

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  static Future<void> inicializar() async {
    if (kIsWeb || _inicializado) return;

    tz_data.initializeTimeZones();

    // Obtém o fuso horário do dispositivo.
    final fuso = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(fuso.identifier));

    const configuracoesAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const configuracoes = InitializationSettings(
      android: configuracoesAndroid,
    );

    await _notifications.initialize(
      settings: configuracoes,
    );

    // Solicita permissão para exibir notificações no Android.
    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();

    _inicializado = true;
  }

  // ============================================================
  // APARÊNCIA DAS NOTIFICAÇÕES
  // ============================================================

  static const NotificationDetails _detalhes = NotificationDetails(
    android: AndroidNotificationDetails(
      _canalId,
      _canalNome,
      channelDescription: 'Lembretes de rega e cuidados do NaliSun.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
  );

  // ============================================================
  // HORÁRIOS
  // ============================================================

  // Cria um horário às 09h para uma data específica.
  static tz.TZDateTime _horarioAsNove(DateTime data) {
    return tz.TZDateTime(
      tz.local,
      data.year,
      data.month,
      data.day,
      9,
    );
  }

  // Retorna o próximo horário válido às 09h.
  // Se hoje já passou das 09h, retorna amanhã às 09h.
  static tz.TZDateTime _proximoHorarioValido() {
    final agora = tz.TZDateTime.now(tz.local);

    var horario = tz.TZDateTime(
      tz.local,
      agora.year,
      agora.month,
      agora.day,
      9,
    );

    if (!horario.isAfter(agora)) {
      horario = tz.TZDateTime(
        tz.local,
        agora.year,
        agora.month,
        agora.day + 1,
        9,
      );
    }

    return horario;
  }

  // ============================================================
  // CONVERSÃO DE DATAS
  // ============================================================

  static DateTime? _converterData(dynamic valor) {
    if (valor == null) return null;

    try {
      if (valor is DateTime) {
        return valor.toLocal();
      }

      return DateTime.parse(valor.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  // Prioridade:
  // 1. Última rega informada pelo histórico.
  // 2. Campo last_watered_at.
  // 3. Data de cadastro da planta.
  static DateTime? _dataReferencia(
    Map<String, dynamic> planta, {
    DateTime? ultimaRega,
  }) {
    return ultimaRega?.toLocal() ??
        _converterData(planta['last_watered_at']) ??
        _converterData(planta['created_at']);
  }

  // ============================================================
  // FREQUÊNCIA DE REGA
  // ============================================================

  static int _frequencia(Map<String, dynamic> planta) {
    final valor = planta['watering_frequency_days'];

    if (valor is num && valor.toInt() > 0) {
      return valor.toInt();
    }

    final frequencia = int.tryParse(valor?.toString() ?? '');

    if (frequencia != null && frequencia > 0) {
      return frequencia;
    }

    return 7;
  }

  // ============================================================
  // IDENTIFICAÇÃO DAS NOTIFICAÇÕES
  // ============================================================

  // Cada planta possui três IDs próprios:
  // tipo 1: aviso um dia antes.
  // tipo 2: aviso no dia da rega.
  // tipo 3: aviso diário de atraso.
  static int _idNotificacao(int plantId, int tipo) {
    return plantId * 10 + tipo;
  }

  // ============================================================
  // CANCELAMENTO
  // ============================================================

  static Future<void> cancelarNotificacoesPlanta(int plantId) async {
    if (kIsWeb || !_inicializado) return;

    for (int tipo = 1; tipo <= 3; tipo++) {
      await _notifications.cancel(
        id: _idNotificacao(plantId, tipo),
      );
    }
  }

  // ============================================================
  // AGENDAMENTO
  // ============================================================

  // Agenda uma notificação para uma data específica.
  // Se o horário das 09h já passou, não transfere a mensagem
  // para o dia seguinte, evitando notificações com texto incorreto.
  static Future<void> _agendarDataEspecifica({
    required int id,
    required String titulo,
    required String mensagem,
    required DateTime data,
  }) async {
    final horario = _horarioAsNove(data);
    final agora = tz.TZDateTime.now(tz.local);

    // Não agenda notificações cuja data e horário já passaram.
    if (!horario.isAfter(agora)) return;

    await _notifications.zonedSchedule(
      id: id,
      title: titulo,
      body: mensagem,
      scheduledDate: horario,
      notificationDetails: _detalhes,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // Agenda uma notificação diária às 09h.
  // A primeira ocorrência será o próximo horário válido.
  static Future<void> _agendarDiariamente({
    required int id,
    required String titulo,
    required String mensagem,
  }) async {
    final horario = _proximoHorarioValido();

    await _notifications.zonedSchedule(
      id: id,
      title: titulo,
      body: mensagem,
      scheduledDate: horario,
      notificationDetails: _detalhes,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ============================================================
  // NOTIFICAÇÕES INDIVIDUAIS DA PLANTA
  // ============================================================

  static Future<void> agendarNotificacoesPlanta(
    Map<String, dynamic> planta, {
    DateTime? ultimaRega,
  }) async {
    if (kIsWeb || !_inicializado) return;

    final plantId = int.tryParse(
      planta['id']?.toString() ?? '',
    );

    if (plantId == null || plantId <= 0) return;

    // Cancela os lembretes anteriores da planta.
    await cancelarNotificacoesPlanta(plantId);

    // Obtém a data de referência.
    final referencia = _dataReferencia(
      planta,
      ultimaRega: ultimaRega,
    );

    if (referencia == null) return;

    final frequencia = _frequencia(planta);

    // Remove o horário da data de referência.
    final dataUltimaRega = DateTime(
      referencia.year,
      referencia.month,
      referencia.day,
    );

    final agora = DateTime.now();

    final hoje = DateTime(
      agora.year,
      agora.month,
      agora.day,
    );

    // Calcula a próxima data prevista para regar.
    final proximaRega = dataUltimaRega.add(
      Duration(days: frequencia),
    );

    final nome = planta['name']?.toString() ?? 'sua planta';

    final umDiaAntes = proximaRega.subtract(
      const Duration(days: 1),
    );

    // ----------------------------------------------------------
    // 1. AVISO UM DIA ANTES
    // ----------------------------------------------------------

    if (!umDiaAntes.isBefore(hoje)) {
      await _agendarDataEspecifica(
        id: _idNotificacao(plantId, 1),
        titulo: 'Rega chegando! 💧',
        mensagem: 'Amanhã é dia de regar $nome.',
        data: umDiaAntes,
      );
    }

    // ----------------------------------------------------------
    // 2. AVISO NO DIA PREVISTO
    // ----------------------------------------------------------

    if (!proximaRega.isBefore(hoje)) {
      await _agendarDataEspecifica(
        id: _idNotificacao(plantId, 2),
        titulo: 'Dia de regar! 🌱',
        mensagem: 'Não se esqueça de regar $nome hoje.',
        data: proximaRega,
      );
    }

    // ----------------------------------------------------------
    // 3. AVISO DIÁRIO DE ATRASO
    // ----------------------------------------------------------

    if (proximaRega.isBefore(hoje)) {
      await _agendarDiariamente(
        id: _idNotificacao(plantId, 3),
        titulo: 'Rega atrasada! 💧',
        mensagem: '$nome está aguardando uma rega.',
      );
    }
  }

  // ============================================================
  // SINCRONIZAÇÃO DAS PLANTAS
  // ============================================================

  static Future<void> sincronizarPlantas(
    List<Map<String, dynamic>> plantas,
  ) async {
    if (kIsWeb || !_inicializado) return;

    for (final planta in plantas) {
      await agendarNotificacoesPlanta(planta);
    }
  }

  // ============================================================
  // LEMBRETE GERAL
  // ============================================================

  static Future<void> agendarLembreteGeral() async {
    if (kIsWeb || !_inicializado) return;

    await _notifications.cancel(
      id: _idLembreteGeral,
    );

    await _agendarDiariamente(
      id: _idLembreteGeral,
      titulo: 'Hora de cuidar do jardim! 🌿',
      mensagem: 'Confira suas plantas e veja se precisam de cuidados.',
    );
  }

  // ============================================================
  // CANCELAR TODAS AS NOTIFICAÇÕES
  // ============================================================

  static Future<void> cancelarTodas() async {
    if (kIsWeb || !_inicializado) return;

    await _notifications.cancelAll();
  }
}