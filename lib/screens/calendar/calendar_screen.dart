// Aba 3: Agenda e Tarefas
//
// Calendário de regas do NaliSun.
// - Utiliza o histórico de regas como referência prioritária.
// - Na ausência de histórico, utiliza a data de cadastro da planta.
// - Calcula as próximas regas conforme a frequência configurada.
// - Mostra os registros realizados nos dias correspondentes.
// - Permite registrar uma rega para o dia atual.

import 'package:flutter/material.dart';

import '../../database/plant_dao.dart';
import '../../database/care_log_dao.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // ============================================================
  // PALETA DE CORES DO NALI-SUN
  // ============================================================

  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeBase = Color(0xFF81B380);
  static const Color verdeAcao = Color(0xFF258A60);
  static const Color amareloCard = Color(0xFFD6D578);
  static const Color textoDetalhe = Color(0xFF897632);

  static const List<String> _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static const List<String> _diasSemana = [
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SÁB',
    'DOM',
  ];

  static const List<String> _diasSemanaCompletos = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];

  // ============================================================
  // ESTADO DA TELA
  // ============================================================

  late DateTime _mesExibido;
  late DateTime _diaSelecionado;

  bool _carregando = true;
  bool _registrandoRega = false;

  String? _erro;

  List<Map<String, dynamic>> _plantas = [];
  List<Map<String, dynamic>> _registros = [];

  @override
  void initState() {
    super.initState();

    final hoje = DateTime.now();

    _mesExibido = DateTime(hoje.year, hoje.month);
    _diaSelecionado = _somenteData(hoje);

    _carregarDados();
  }

  // ============================================================
  // DATAS
  // ============================================================

  DateTime _somenteData(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }

  DateTime? _lerData(dynamic valor) {
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

  DateTime? _lerDataLocal(Map<String, dynamic> mapa, String campo) {
    return _lerData(mapa[campo]);
  }

  int _lerId(dynamic valor) {
    if (valor is num) return valor.toInt();

    return int.tryParse(valor?.toString() ?? '') ?? -1;
  }

  // ============================================================
  // CARREGAMENTO DOS DADOS
  // ============================================================

  Future<void> _carregarDados() async {
    if (!mounted) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      // Busca somente as plantas do usuário autenticado.
      final plantas = await PlantDAO.getPlantsByUser();

      final ids = plantas
          .map((planta) => _lerId(planta['id']))
          .where((id) => id > 0)
          .toList();

      // Sem plantas, não precisamos consultar o histórico.
      final registros = ids.isEmpty
          ? <Map<String, dynamic>>[]
          : await CareLogDAO.getCareLogsByUser(
              plantIds: ids,
            );

      if (!mounted) return;

      setState(() {
        _plantas = plantas;
        _registros = registros;
        _carregando = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar calendário: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _erro = 'Não foi possível carregar o calendário.';
        _carregando = false;
      });
    }
  }

  // ============================================================
  // HISTÓRICO DE REGAS
  // ============================================================

  /// Retorna os registros de rega de uma planta.
  List<Map<String, dynamic>> _regasDaPlanta(int plantId) {
    return _registros.where((registro) {
      final idRegistro = _lerId(registro['plant_id']);

      final tipo = registro['care_type']
          ?.toString()
          .trim()
          .toLowerCase();

      return idRegistro == plantId && tipo == 'watering';
    }).toList();
  }

  /// Retorna a última rega conhecida.
  ///
  /// O histórico tem prioridade. O campo last_watered_at é
  /// utilizado como alternativa quando não há registros válidos.
  DateTime? _ultimaRega(Map<String, dynamic> planta) {
    final id = _lerId(planta['id']);
    final regas = _regasDaPlanta(id);

    DateTime? ultima;

    for (final registro in regas) {
      final data = _lerData(registro['performed_at']);

      if (data != null &&
          (ultima == null || data.isAfter(ultima))) {
        ultima = data;
      }
    }

    if (ultima != null) {
      return ultima;
    }

    return _lerData(planta['last_watered_at']);
  }

  /// Frequência de rega configurada no cadastro.
  int _frequencia(Map<String, dynamic> planta) {
    final valor = planta['watering_frequency_days'];

    if (valor is num && valor.toInt() > 0) {
      return valor.toInt();
    }

    final convertido = int.tryParse(valor?.toString() ?? '');

    if (convertido != null && convertido > 0) {
      return convertido;
    }

    // Valor padrão quando a frequência não está preenchida.
    return 7;
  }

  /// Data de cadastro da planta.
  DateTime? _dataCadastro(Map<String, dynamic> planta) {
    return _lerData(planta['created_at']);
  }

  /// Define a referência para calcular a próxima rega.
  ///
  /// Prioridade:
  /// 1. Última rega registrada no histórico.
  /// 2. Campo last_watered_at da planta.
  /// 3. Data de cadastro da planta.
  DateTime? _dataReferencia(Map<String, dynamic> planta) {
    return _ultimaRega(planta) ?? _dataCadastro(planta);
  }

  // ============================================================
  // PREVISÕES
  // ============================================================

  /// Verifica se a planta tem uma rega prevista na data informada.
  ///
  /// Exemplo:
  /// Cadastro em 01/11 + frequência de 7 dias = primeira previsão
  /// em 08/11, desde que não exista histórico de rega.
  bool _plantaPrecisaRegarEm(
    Map<String, dynamic> planta,
    DateTime data,
  ) {
    final referencia = _dataReferencia(planta);

    // Sem data de cadastro nem histórico, não é possível calcular.
    if (referencia == null) {
      return false;
    }

    final diaBase = _somenteData(referencia);
    final diaConsultado = _somenteData(data);

    // A primeira previsão ocorre após o intervalo configurado.
    if (!diaConsultado.isAfter(diaBase)) {
      return false;
    }

    final diferenca = diaConsultado.difference(diaBase).inDays;

    return diferenca > 0 &&
        diferenca % _frequencia(planta) == 0;
  }

  /// Verifica se existe uma rega registrada no dia selecionado.
  bool _regadaEm(
    Map<String, dynamic> planta,
    DateTime data,
  ) {
    final id = _lerId(planta['id']);
    final dia = _somenteData(data);

    return _regasDaPlanta(id).any((registro) {
      final realizada = _lerData(registro['performed_at']);

      return realizada != null &&
          _somenteData(realizada) == dia;
    });
  }

  /// Uma planta aparece na lista quando:
  /// - possui rega prevista para o dia; ou
  /// - possui uma rega registrada naquele dia.
  List<Map<String, dynamic>> _tarefasDoDia(DateTime data) {
    return _plantas.where((planta) {
      return _plantaPrecisaRegarEm(planta, data) ||
          _regadaEm(planta, data);
    }).toList();
  }

  /// Quantidade de plantas que possuem eventos na data.
  int _quantidadeIndicadores(DateTime data) {
    return _tarefasDoDia(data).length;
  }

  // ============================================================
  // REGISTRAR REGA
  // ============================================================

  Future<void> _marcarComoRegada(
    Map<String, dynamic> planta,
  ) async {
    if (_registrandoRega) return;

    final hoje = _somenteData(DateTime.now());
    final diaEscolhido = _somenteData(_diaSelecionado);

    // O DAO atual registra a data da execução.
    // Portanto, não permitimos registrar uma rega futura ou
    // retroativa por meio de uma data selecionada no calendário.
    if (diaEscolhido != hoje) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Para registrar a rega, selecione a data de hoje.',
          ),
        ),
      );
      return;
    }

    final id = _lerId(planta['id']);

    if (id <= 0) {
      _mostrarMensagem('Não foi possível identificar esta planta.');
      return;
    }

    if (_regadaEm(planta, hoje)) {
      _mostrarMensagem(
        'Esta planta já possui uma rega registrada hoje.',
      );
      return;
    }

    setState(() {
      _registrandoRega = true;
    });

    try {
      await CareLogDAO.registrarRega(
        plantId: id,
      );

      // Recarrega o histórico para recalcular as próximas datas.
      await _carregarDados();

      if (!mounted) return;

      _mostrarMensagem(
        'Rega de ${planta['name'] ?? 'planta'} registrada com sucesso!',
      );
    } catch (e, stackTrace) {
      debugPrint('Erro ao registrar rega: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _mostrarMensagem(
        'Não foi possível registrar a rega. Tente novamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _registrandoRega = false;
        });
      }
    }
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: verdeEscuro,
      ),
    );
  }

  // ============================================================
  // NAVEGAÇÃO DO CALENDÁRIO
  // ============================================================

  void _mudarMes(int quantidade) {
    setState(() {
      _mesExibido = DateTime(
        _mesExibido.year,
        _mesExibido.month + quantidade,
      );

      final ultimoDia = DateTime(
        _mesExibido.year,
        _mesExibido.month + 1,
        0,
      ).day;

      if (_diaSelecionado.year != _mesExibido.year ||
          _diaSelecionado.month != _mesExibido.month) {
        _diaSelecionado = DateTime(
          _mesExibido.year,
          _mesExibido.month,
          _diaSelecionado.day.clamp(1, ultimoDia).toInt(),
        );
      }
    });
  }

  String _formatarData(DateTime data) {
    return '${_diasSemanaCompletos[data.weekday - 1]}, '
        '${data.day} de '
        '${_meses[data.month - 1].toLowerCase()}';
  }

  // ============================================================
  // BUILD PRINCIPAL
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final escuro = tema.brightness == Brightness.dark;
    final texto = tema.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(escuro),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _carregarDados,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSeletorMes(escuro),
                      const SizedBox(height: 12),
                      if (_carregando)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_erro != null)
                        _buildErro(escuro)
                      else ...[
                        _buildCardCalendario(escuro),
                        const SizedBox(height: 20),
                        _buildSecaoTarefasDoDia(
                          escuro,
                          texto,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERRO DE CARREGAMENTO
  // ============================================================

  Widget _buildErro(bool escuro) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(
          Icons.cloud_off_outlined,
          size: 36,
          color: escuro ? verdeBase : verdeEscuro,
        ),
        const SizedBox(height: 8),
        Text(
          _erro!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: escuro ? Colors.white : verdeEscuro,
          ),
        ),
        TextButton(
          onPressed: _carregarDados,
          child: const Text('Tentar novamente'),
        ),
      ],
    );
  }

  // ============================================================
  // CABEÇALHO
  // ============================================================

  Widget _buildHeader(bool escuro) {
    final corFundo = escuro
        ? const Color(0xFF102A2E)
        : verdeEscuro;

    final corTexto = escuro
        ? Colors.white
        : fundoBege;

    return Container(
      width: double.infinity,
      color: corFundo,
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarefas do Dia',
            style: TextStyle(
              color: corTexto,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Um pouco de atenção, todos os dias.',
            style: TextStyle(
              color: corTexto,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELETOR DE MÊS
  // ============================================================

  Widget _buildSeletorMes(bool escuro) {
    final corTexto = escuro ? Colors.white : verdeEscuro;

    final diasNoMes = DateTime(
      _mesExibido.year,
      _mesExibido.month + 1,
      0,
    ).day;

    final primeiroDia = DateTime(
      _mesExibido.year,
      _mesExibido.month,
      1,
    );

    final textoInicio =
        _diasSemanaCompletos[primeiroDia.weekday - 1];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: escuro
              ? const [
                  Color(0xFF29483F),
                  Color(0xFF203A36),
                ]
              : const [
                  fundoBege,
                  amareloCard,
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.chevron_left,
              color: corTexto,
            ),
            onPressed: () => _mudarMes(-1),
          ),
          Flexible(
            child: Column(
              children: [
                Text(
                  '${_meses[_mesExibido.month - 1]} '
                  '${_mesExibido.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$diasNoMes dias · começa $textoInicio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: corTexto.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.chevron_right,
              color: corTexto,
            ),
            onPressed: () => _mudarMes(1),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CALENDÁRIO
  // ============================================================

  Widget _buildCardCalendario(bool escuro) {
    final corCartao = escuro
        ? const Color(0xFF1B383C)
        : verdeBase;

    final corCelula = escuro
        ? const Color(0xFF294448)
        : fundoBege;

    final corTexto = escuro ? Colors.white : verdeEscuro;

    final corEvento = escuro
        ? const Color(0xFFA7D8A5)
        : verdeEscuro;

    final corSelecionado = escuro
        ? const Color(0xFF81B380)
        : verdeAcao;

    final corTextoSelecionado = escuro
        ? const Color(0xFF102A2E)
        : fundoBege;

    final diasNoMes = DateTime(
      _mesExibido.year,
      _mesExibido.month + 1,
      0,
    ).day;

    final deslocamento = DateTime(
      _mesExibido.year,
      _mesExibido.month,
      1,
    ).weekday - 1;

    final totalCelulas =
        ((deslocamento + diasNoMes + 6) ~/ 7) * 7;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: corCartao,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: _diasSemana.map((dia) {
              return Expanded(
                child: Text(
                  dia,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCelulas,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final numeroDia = index - deslocamento + 1;

              if (numeroDia < 1 || numeroDia > diasNoMes) {
                return const SizedBox.shrink();
              }

              final data = DateTime(
                _mesExibido.year,
                _mesExibido.month,
                numeroDia,
              );

              final selecionado =
                  _somenteData(data) ==
                  _somenteData(_diaSelecionado);

              final quantidadeEventos =
                  _quantidadeIndicadores(data);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _diaSelecionado = data;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selecionado
                        ? corSelecionado
                        : corCelula,
                    borderRadius: BorderRadius.circular(10),
                    border: selecionado
                        ? Border.all(
                            color: escuro
                                ? verdeBase
                                : verdeEscuro,
                            width: 1.2,
                          )
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$numeroDia',
                        style: TextStyle(
                          color: selecionado
                              ? corTextoSelecionado
                              : corTexto,
                          fontSize: 13,
                          fontWeight: selecionado
                              ? FontWeight.bold
                              : FontWeight.w400,
                        ),
                      ),
                      if (quantidadeEventos > 0)
                        Positioned(
                          bottom: 2,
                          child: Icon(
                            Icons.water_drop,
                            size: 9,
                            color: const Color.fromARGB(255, 53, 164, 255),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildItemLegenda(
                'Rega prevista ou realizada',
                corEvento,
                corTexto,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemLegenda(
    String rotulo,
    Color cor,
    Color corTexto,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            rotulo,
            style: TextStyle(
              color: corTexto,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TAREFAS DO DIA
  // ============================================================

  Widget _buildSecaoTarefasDoDia(
    bool escuro,
    Color corTexto,
  ) {
    final corEtiqueta = escuro
        ? const Color(0xFF29483F)
        : verdeBase;

    final tarefas = _tarefasDoDia(_diaSelecionado);

    final concluidas = tarefas.where(
      (planta) => _regadaEm(planta, _diaSelecionado),
    ).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _formatarData(_diaSelecionado),
                style: TextStyle(
                  color: corTexto,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: corEtiqueta,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${tarefas.length} '
                '${tarefas.length == 1 ? 'tarefa' : 'tarefas'}',
                style: TextStyle(
                  color: escuro ? Colors.white : verdeEscuro,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (tarefas.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: escuro
                  ? const Color(0xFF1B383C)
                  : fundoBege,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: verdeBase.withValues(
                  alpha: escuro ? 0.6 : 0.5,
                ),
              ),
            ),
            child: Text(
              _plantas.isEmpty
                  ? 'Você ainda não cadastrou plantas no seu jardim.'
                  : 'Nenhuma rega prevista para este dia.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: escuro ? Colors.white : verdeEscuro,
                fontSize: 12,
              ),
            ),
          )
        else
          ...tarefas.map((planta) {
            final regada =
                _regadaEm(planta, _diaSelecionado);

            final ultima = _ultimaRega(planta);
            final cadastro = _dataCadastro(planta);
            final frequencia = _frequencia(planta);

            final subtitulo = regada
                ? 'Rega registrada neste dia'
                : ultima != null
                    ? 'Última rega: '
                        '${_formatarData(ultima)} · '
                        'Intervalo de $frequencia dias'
                    : cadastro != null
                        ? 'Primeira rega calculada a partir '
                            'do cadastro · $frequencia dias'
                        : 'Sem data de referência';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildItemTarefa(
                titulo: 'Regar ${planta['name'] ?? 'Planta'}',
                subtitulo: subtitulo,
                concluida: regada,
                escuro: escuro,
                onTap: regada || _registrandoRega
                    ? null
                    : () => _marcarComoRegada(planta),
                carregando: _registrandoRega,
              ),
            );
          }),

        const SizedBox(height: 8),

        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: escuro ? verdeBase : textoDetalhe,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$concluidas cuidados concluídos. '
                'Seu jardim agradece!',
                style: TextStyle(
                  color: escuro
                      ? const Color(0xFFB8CCC5)
                      : textoDetalhe,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ITEM DE TAREFA
  // ============================================================

  Widget _buildItemTarefa({
    required String titulo,
    required String subtitulo,
    required bool concluida,
    required bool escuro,
    required VoidCallback? onTap,
    required bool carregando,
  }) {
    final corFundo = escuro
        ? const Color(0xFF1B383C)
        : fundoBege;

    final corTexto = escuro ? Colors.white : verdeEscuro;

    final corDetalhe = escuro
        ? const Color(0xFFB8CCC5)
        : textoDetalhe;

    final corIcone = escuro ? verdeBase : verdeEscuro;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: verdeBase.withValues(
              alpha: escuro ? 0.6 : 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.water_drop_outlined,
              color: corIcone,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: concluida
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      color: corDetalhe,
                      fontSize: 11,
                    ),
                  ),
                  if (!concluida) ...[
                    const SizedBox(height: 4),
                    Text(
                      _somenteData(_diaSelecionado) ==
                              _somenteData(DateTime.now())
                          ? 'Toque para registrar a rega'
                          : 'Selecione hoje para registrar a rega',
                      style: TextStyle(
                        color: corDetalhe,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (carregando)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            else
              Icon(
                concluida
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: concluida ? verdeBase : corIcone,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
