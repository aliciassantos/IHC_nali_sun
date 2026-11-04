import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../database/plant_dao.dart';
import '../../models/plant_model.dart';

class HomeScreen extends StatefulWidget {
  // Callback recebido do MainNavigationScreen.
  final ValueChanged<int>? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // =========================================================
  // PALETA ORIGINAL NALI-SUN
  // =========================================================

  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeBase = Color(0xFF81B380);
  static const Color verdeAcao = Color(0xFF258A60);
  static const Color amareloCard = Color(0xFFD6D578);
  static const Color verdeAvisoCard = Color(0xFF5AA68C);
  static const Color verdeChartreuse = Color(0xFFA7BF73);
  static const Color textoCardEscuro = Color(0xFF392E0E);
  static const Color textoNavUnselected = Color(0xFFDACB8A);

  // =========================================================
  // FUTURE DAS PLANTAS
  // =========================================================

  late Future<List<PlantModel>> _futurePlantas;
  List<_PlantaComRega> _regasAtuais = [];

  int get _quantidadeNotificacoes {
    return _regasAtuais.where((rega) => rega.diasRestantes <= 1).length;
  }

  @override
  void initState() {
    super.initState();
    _futurePlantas = _carregarPlantas();
  }

  // =========================================================
  // CARREGAR PLANTAS DO USUÁRIO
  // =========================================================

  Future<List<PlantModel>> _carregarPlantas() async {
    try {
      final resposta = await PlantDAO.getPlantsByUser();

      debugPrint('================================');
      debugPrint('HOME - TOTAL DE PLANTAS: ${resposta.length}');

      for (final planta in resposta) {
        debugPrint(
          'PLANTA: ${planta['name']} | '
          'IMAGEM: ${planta['image_path']}',
        );
      }

      debugPrint('================================');

      final plantas = resposta.map((mapa) {
        return PlantModel.fromMap(Map<String, dynamic>.from(mapa));
      }).toList();

      // ADICIONAR AQUI: calcular as regas das plantas carregadas.
      final regas = _calcularRegas(plantas);

      if (mounted) {
        setState(() {
          _regasAtuais = regas;
        });
      }

      return plantas;
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar plantas da Home: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // =========================================================
  // ATUALIZAR PLANTAS
  // =========================================================

  Future<void> _atualizarPlantas() async {
    if (!mounted) return;

    final novoFuture = _carregarPlantas();

    setState(() {
      _futurePlantas = novoFuture;
    });

    try {
      await novoFuture;
    } catch (e) {
      debugPrint('Erro ao atualizar plantas da Home: $e');
    }
  }

  // Método público utilizado pelo MainNavigationScreen.
  Future<void> atualizarPlantas() async {
    if (!mounted) return;

    await _atualizarPlantas();
  }

  // =========================================================
  // CÁLCULO DAS PRÓXIMAS REGAS
  // =========================================================

  DateTime _inicioDoDia(DateTime data) {
    final local = data.toLocal();

    return DateTime(local.year, local.month, local.day);
  }

  List<_PlantaComRega> _calcularRegas(List<PlantModel> plantas) {
    final hoje = _inicioDoDia(DateTime.now());

    final regas = plantas.map((planta) {
      // Se não existe uma última rega registrada,
      // utiliza a data de cadastro como referência.
      final ultimaRega = planta.lastWateredAt ?? planta.createdAt;

      final dataBase = _inicioDoDia(ultimaRega);

      final frequencia = planta.wateringFrequencyDays > 0
          ? planta.wateringFrequencyDays
          : 1;

      final proximaRega = dataBase.add(Duration(days: frequencia));

      final diasRestantes = proximaRega.difference(hoje).inDays;

      return _PlantaComRega(
        planta: planta,
        proximaRega: proximaRega,
        diasRestantes: diasRestantes,
      );
    }).toList();

    // Organiza da rega mais próxima para a mais distante.
    regas.sort((a, b) => a.proximaRega.compareTo(b.proximaRega));

    return regas;
  }

  // =========================================================
  // FORMATAÇÃO DE DATAS
  // =========================================================

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  String _textoPrazo(_PlantaComRega rega) {
    final dias = rega.diasRestantes;

    if (dias < 0) {
      final atraso = dias.abs();

      return atraso == 1 ? 'Atrasada · 1 dia' : 'Atrasada · $atraso dias';
    }

    if (dias == 0) {
      return 'Hoje · Rega programada';
    }

    if (dias == 1) {
      return 'Amanhã · Próxima rega';
    }

    return 'Em $dias dias · ${_formatarData(rega.proximaRega)}';
  }

  String _textoDestaque(_PlantaComRega rega) {
    final dias = rega.diasRestantes;

    if (dias < 0) {
      final atraso = dias.abs();

      return atraso == 1 ? 'Atrasada há 1 dia' : 'Atrasada há $atraso dias';
    }

    if (dias == 0) return 'Hoje';
    if (dias == 1) return 'Amanhã';

    return 'Em $dias dias';
  }

  String _nomesDasPlantas(List<_PlantaComRega> regas) {
    if (regas.isEmpty) return '';

    return regas.map((rega) => rega.planta.name).join(', ');
  }

  void _mostrarNotificacoes() {
    final atrasadas = _regasAtuais
        .where((rega) => rega.diasRestantes < 0)
        .toList();

    final paraHoje = _regasAtuais
        .where((rega) => rega.diasRestantes == 0)
        .toList();

    final paraAmanha = _regasAtuais
        .where((rega) => rega.diasRestantes == 1)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: fundoBege,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: verdeBase,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: verdeEscuro,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Notificações',
                          style: TextStyle(
                            color: verdeEscuro,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: verdeEscuro),
                      ),
                    ],
                  ),

                  const Text(
                    'Confira os lembretes de rega das suas plantas.',
                    style: TextStyle(color: textoCardEscuro, fontSize: 14),
                  ),

                  const SizedBox(height: 20),

                  if (_regasAtuais.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 45,
                              color: verdeBase,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Nenhum lembrete no momento.',
                              style: TextStyle(
                                color: verdeEscuro,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    _buildGrupoNotificacoes(
                      'Regas atrasadas',
                      atrasadas,
                      Icons.warning_amber_rounded,
                    ),

                    _buildGrupoNotificacoes(
                      'Regas para hoje',
                      paraHoje,
                      Icons.water_drop_outlined,
                    ),

                    _buildGrupoNotificacoes(
                      'Regas para amanhã',
                      paraAmanha,
                      Icons.calendar_today_outlined,
                    ),
                  ],

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onNavigateToTab?.call(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verdeEscuro,
                        foregroundColor: fundoBege,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Ver minhas plantas'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrupoNotificacoes(
    String titulo,
    List<_PlantaComRega> regas,
    IconData icone,
  ) {
    if (regas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 12),
          child: Text(
            titulo,
            style: const TextStyle(
              color: verdeEscuro,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        ...regas.map(
          (rega) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icone, color: verdeAcao, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rega.planta.name,
                        style: const TextStyle(
                          color: verdeEscuro,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _textoPrazo(rega),
                        style: const TextStyle(
                          color: textoCardEscuro,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CONSTRUIR TELA
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().currentUser;

    final tema = Theme.of(context);
    final escuro = tema.brightness == Brightness.dark;

    final texto = tema.colorScheme.onSurface;
    final destaque = escuro ? verdeBase : verdeAcao;

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              nomeUsuario: usuario?.name ?? 'Usuário',
              fotoUsuario: usuario?.avatarPath,
              escuro: escuro,
            ),

            Expanded(
              child: FutureBuilder<List<PlantModel>>(
                future: _futurePlantas,
                builder: (context, snapshot) {
                  final carregando =
                      snapshot.connectionState == ConnectionState.waiting;

                  if (carregando) {
                    return const Center(
                      child: CircularProgressIndicator(color: verdeAcao),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildErroCarregamento(escuro);
                  }

                  final plantas = snapshot.data ?? [];

                  // Calcula as datas das regas.
                  final regas = _calcularRegas(plantas);

                  // Plantas com rega atrasada.
                  final atrasadas = regas
                      .where((rega) => rega.diasRestantes < 0)
                      .toList();

                  // Plantas que precisam ser regadas hoje.
                  final regarHoje = regas
                      .where((rega) => rega.diasRestantes == 0)
                      .toList();

                  // Plantas com regas futuras.
                  final proximasRegas = regas
                      .where((rega) => rega.diasRestantes > 0)
                      .toList();

                  return RefreshIndicator(
                    color: verdeAcao,
                    onRefresh: _atualizarPlantas,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // PRÓXIMA REGA.
                          _buildProximaRegaCard(escuro, regas),

                          const SizedBox(height: 16),

                          // CARDS DE NAVEGAÇÃO.
                          _buildGridAcoes(
                            escuro,
                            quantidadePlantas: plantas.length,
                            quantidadeRegasHoje: regarHoje.length,
                          ),

                          const SizedBox(height: 24),

                          // PLANTAS ATRASADAS.
                          _buildTituloSecao(
                            'Precisa de Atenção',
                            '${atrasadas.length} '
                                '${atrasadas.length == 1 ? 'planta' : 'plantas'}',
                            destaque,
                            texto,
                          ),

                          const SizedBox(height: 10),

                          if (atrasadas.isEmpty)
                            _buildEstadoVazio(
                              titulo: 'Tudo em dia!',
                              subtitulo:
                                  'Nenhuma planta está com a rega atrasada.',
                              icone: Icons.check_circle_outline,
                              escuro: escuro,
                            )
                          else
                            ...atrasadas.map(
                              (rega) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildAvisoCard(
                                  titulo: rega.planta.name,
                                  subtitulo:
                                      '${rega.planta.species} · '
                                      '${_textoPrazo(rega)}',
                                  imagemPath: rega.planta.imagePath,
                                  corFundo: escuro
                                      ? const Color(0xFF493334)
                                      : const Color(0xFFF4D3CC),
                                  corBorda: const Color(0xFFE53935),
                                  icone: Icons.warning_amber_rounded,
                                  corIcone: const Color(0xFFE53935),
                                  escuro: escuro,
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),

                          // REGAS DE HOJE.
                          _buildTituloSecao(
                            'Regar Hoje',
                            '${regarHoje.length} '
                                '${regarHoje.length == 1 ? 'cuidado' : 'cuidados'}',
                            destaque,
                            texto,
                          ),

                          const SizedBox(height: 10),

                          if (regarHoje.isEmpty)
                            _buildEstadoVazio(
                              titulo: 'Nenhuma rega para hoje',
                              subtitulo:
                                  'Suas plantas não possuem regas programadas para esta data.',
                              icone: Icons.water_drop_outlined,
                              escuro: escuro,
                            )
                          else
                            ...regarHoje.map(
                              (rega) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildAvisoCard(
                                  titulo: rega.planta.name,
                                  subtitulo:
                                      '${rega.planta.species} · '
                                      '${_textoPrazo(rega)}',
                                  imagemPath: rega.planta.imagePath,
                                  corFundo: escuro
                                      ? const Color(0xFF493F2C)
                                      : amareloCard,
                                  corBorda: const Color(0xFFF59E0B),
                                  icone: Icons.water_drop_outlined,
                                  corIcone: const Color(0xFFE58B16),
                                  escuro: escuro,
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),

                          // PRÓXIMAS REGAS.
                          _buildTituloSecao(
                            'Próximas Regas',
                            '${proximasRegas.length} '
                                '${proximasRegas.length == 1 ? 'planta' : 'plantas'}',
                            destaque,
                            texto,
                          ),

                          const SizedBox(height: 10),

                          if (proximasRegas.isEmpty)
                            _buildEstadoVazio(
                              titulo: 'Nenhuma rega futura cadastrada',
                              subtitulo: 'As próximas regas aparecerão aqui.',
                              icone: Icons.eco_outlined,
                              escuro: escuro,
                            )
                          else
                            ...proximasRegas.map(
                              (rega) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildAvisoCard(
                                  titulo: rega.planta.name,
                                  subtitulo:
                                      '${rega.planta.species} · '
                                      '${_textoPrazo(rega)}',
                                  imagemPath: rega.planta.imagePath,
                                  corFundo: escuro
                                      ? const Color(0xFF24463D)
                                      : verdeBase,
                                  corBorda: verdeBase,
                                  icone: Icons.check_circle_outline,
                                  corIcone: escuro ? verdeBase : verdeEscuro,
                                  escuro: escuro,
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CABEÇALHO
  // =========================================================

  Widget _buildHeader({
    required String nomeUsuario,
    required String? fotoUsuario,
    required bool escuro,
  }) {
    final fundoHeader = escuro ? const Color(0xFF102A2E) : verdeEscuro;

    final textoHeader = escuro ? Colors.white : fundoBege;

    final urlFoto = fotoUsuario != null && fotoUsuario.trim().isNotEmpty
        ? Supabase.instance.client.storage
              .from('avatars')
              .getPublicUrl(fotoUsuario)
        : null;

    return Container(
      width: double.infinity,
      color: fundoHeader,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Nali-Sun',
                      style: TextStyle(
                        color: textoHeader,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.eco, color: verdeBase, size: 20),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Bem-vinda, $nomeUsuario!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textoHeader,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // SINO DE NOTIFICAÇÕES
          GestureDetector(
            onTap: _mostrarNotificacoes,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: escuro ? const Color(0xFF304B4E) : amareloCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: verdeBase, width: 2),
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: fundoBege,
                    size: 24,
                  ),
                ),

                if (_quantidadeNotificacoes > 0)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: fundoBege, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _quantidadeNotificacoes > 9
                              ? '9+'
                              : '$_quantidadeNotificacoes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // FOTO DO PERFIL
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: escuro ? const Color(0xFF304B4E) : amareloCard,
              shape: BoxShape.circle,
              border: Border.all(color: verdeBase, width: 2),
            ),
            child: ClipOval(
              child: urlFoto != null
                  ? Image.network(
                      urlFoto,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: escuro ? Colors.white : verdeEscuro,
                        );
                      },
                    )
                  : Icon(
                      Icons.person,
                      color: escuro ? Colors.white : verdeEscuro,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PRÓXIMA REGA DO JARDIM
  // =========================================================

  Widget _buildProximaRegaCard(bool escuro, List<_PlantaComRega> regas) {
    final corTexto = escuro ? Colors.white : verdeEscuro;

    final proxima = regas.isNotEmpty ? regas.first : null;

    final mesmaData = proxima == null
        ? <_PlantaComRega>[]
        : regas
              .where(
                (rega) =>
                    _inicioDoDia(rega.proximaRega) ==
                    _inicioDoDia(proxima.proximaRega),
              )
              .toList();

    final nomes = _nomesDasPlantas(mesmaData);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: escuro
              ? const [Color(0xFF28594B), Color(0xFF1B4039)]
              : const [verdeAvisoCard, verdeBase],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Próxima Rega do Jardim',
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.water_drop_outlined, color: corTexto, size: 22),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            proxima == null ? 'Jardim vazio' : _textoDestaque(proxima),
            style: TextStyle(
              color: corTexto,
              fontSize: proxima == null ? 25 : 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: escuro ? const Color(0xFF426B58) : verdeChartreuse,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              proxima == null
                  ? 'Cadastre uma planta em Meu Jardim'
                  : '$nomes · ${_formatarData(proxima.proximaRega)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: escuro ? Colors.white : verdeEscuro,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ATALHOS DA HOME - NAVEGAÇÃO PELO MAIN NAVIGATION
  // =========================================================

  Widget _buildGridAcoes(
    bool escuro, {
    required int quantidadePlantas,
    required int quantidadeRegasHoje,
  }) {
    final gradientePlantas = escuro
        ? const LinearGradient(colors: [Color(0xFF29483E), Color(0xFF203C36)])
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [verdeChartreuse, verdeBase],
          );

    final gradienteCalendario = escuro
        ? const LinearGradient(colors: [Color(0xFF254A45), Color(0xFF1C3936)])
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [verdeBase, verdeAvisoCard],
          );

    final gradienteDicas = escuro
        ? const LinearGradient(colors: [Color(0xFF49452D), Color(0xFF353D2D)])
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [amareloCard, verdeChartreuse],
          );

    final gradientePerfil = escuro
        ? const LinearGradient(colors: [Color(0xFF344649), Color(0xFF263A3D)])
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [textoNavUnselected, fundoBege],
          );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniCard(
                'Minhas Plantas',
                '$quantidadePlantas '
                    '${quantidadePlantas == 1 ? 'planta' : 'plantas'}',
                Icons.eco_outlined,
                gradientePlantas,
                escuro,
                onTap: () {
                  widget.onNavigateToTab?.call(1);
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildMiniCard(
                'Calendário de Cuidados',
                '$quantidadeRegasHoje '
                    '${quantidadeRegasHoje == 1 ? 'cuidado' : 'cuidados'} hoje',
                Icons.calendar_today_outlined,
                gradienteCalendario,
                escuro,
                onTap: () {
                  widget.onNavigateToTab?.call(2);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildMiniCard(
                'Dicas de Cultivo',
                '12 artigos disponíveis',
                Icons.menu_book_outlined,
                gradienteDicas,
                escuro,
                onTap: () {
                  widget.onNavigateToTab?.call(3);
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildMiniCard(
                'Meu perfil',
                'Customize seu perfil',
                Icons.person_outline,
                gradientePerfil,
                escuro,
                onTap: () {
                  widget.onNavigateToTab?.call(4);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // CARD CLICÁVEL
  // =========================================================

  Widget _buildMiniCard(
    String titulo,
    String subtitulo,
    IconData icone,
    Gradient gradiente,
    bool escuro, {
    VoidCallback? onTap,
  }) {
    final corTexto = escuro ? Colors.white : verdeEscuro;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 106,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: gradiente,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icone, color: corTexto, size: 22),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: escuro ? const Color(0xFFD4E1DC) : verdeEscuro,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // IMAGEM DA PLANTA
  // =========================================================

  Widget _construirImagemPlanta({
    required String? imagemPath,
    required bool escuro,
  }) {
    final corFundo = escuro ? const Color(0xFF294448) : fundoBege;

    Widget imagemAlternativa() {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: corFundo,
        alignment: Alignment.center,
        child: Icon(
          Icons.eco,
          color: escuro ? verdeBase : verdeEscuro,
          size: 28,
        ),
      );
    }

    if (imagemPath == null || imagemPath.trim().isEmpty) {
      return imagemAlternativa();
    }

    final url = imagemPath.trim();

    // As imagens salvas pelo cadastro são URLs do Supabase.
    if (!url.startsWith('https://') && !url.startsWith('http://')) {
      return imagemAlternativa();
    }

    return Image.network(
      url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          color: corFundo,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: verdeAcao),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Erro ao carregar imagem da planta: $error');
        return imagemAlternativa();
      },
    );
  }

  // =========================================================
  // TÍTULOS DAS SEÇÕES
  // =========================================================

  Widget _buildTituloSecao(
    String titulo,
    String acao,
    Color corAcao,
    Color corTexto,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              color: corTexto,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          acao,
          style: TextStyle(
            color: corAcao,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CARDS DE REGAS COM IMAGEM
  // =========================================================

  Widget _buildAvisoCard({
    required String titulo,
    required String subtitulo,
    required String? imagemPath,
    required Color corFundo,
    required Color corBorda,
    required IconData icone,
    required Color corIcone,
    required bool escuro,
  }) {
    final corTexto = escuro ? Colors.white : textoCardEscuro;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: corFundo,
        border: Border.all(color: corBorda, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // FOTO DA PLANTA.
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 52,
              height: 52,
              child: _construirImagemPlanta(
                imagemPath: imagemPath,
                escuro: escuro,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // NOME E INFORMAÇÕES DA PLANTA.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ÍCONE DE STATUS DA REGA.
          Icon(icone, color: corIcone, size: 22),
        ],
      ),
    );
  }

  // =========================================================
  // ESTADO VAZIO DAS SEÇÕES
  // =========================================================

  Widget _buildEstadoVazio({
    required String titulo,
    required String subtitulo,
    required IconData icone,
    required bool escuro,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: escuro ? const Color(0xFF1B383C) : fundoBege,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icone, color: verdeAcao, size: 28),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: escuro ? fundoBege : verdeEscuro,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitulo,
                  style: TextStyle(
                    color: escuro ? Colors.white70 : verdeEscuro,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ERRO AO CARREGAR AS PLANTAS
  // =========================================================

  Widget _buildErroCarregamento(bool escuro) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Colors.orange,
              size: 45,
            ),

            const SizedBox(height: 12),

            Text(
              'Não foi possível carregar seu jardim.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: escuro ? fundoBege : verdeEscuro,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Verifique sua conexão e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: escuro ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: atualizarPlantas,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeAcao,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// MODELO AUXILIAR PARA ORGANIZAR AS REGAS
// ===========================================================

class _PlantaComRega {
  final PlantModel planta;
  final DateTime proximaRega;
  final int diasRestantes;

  const _PlantaComRega({
    required this.planta,
    required this.proximaRega,
    required this.diasRestantes,
  });
}
