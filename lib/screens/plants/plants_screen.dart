// Aba 2: Meu Jardim e Detalhes

import 'package:flutter/material.dart';
import 'add_plants_screen.dart';
import 'package:nali_sun_app/database/plant_dao.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  // ==================== PALETA DE CORES ====================

  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeBase = Color(0xFF81B380);
  static const Color verdeAcao = Color(0xFF258A60);
  static const Color amareloCard = Color(0xFFD6D578);
  static const Color verdeChartreuse = Color(0xFFA7BF73);

  // ==================== ESTADO DA TELA ====================

  List<Map<String, dynamic>> _plantas = [];

  bool _carregando = true;

  String? _erro;

  // ==================== CICLO DE VIDA ====================

  @override
  void initState() {
    super.initState();
    _carregarPlantas();
  }

  // ==================== CARREGAR PLANTAS ====================

  Future<void> _carregarPlantas() async {
    if (!mounted) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final plantas = await PlantDAO.getPlantsByUser();

      if (!mounted) return;

      setState(() {
        _plantas = plantas;
        _carregando = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar plantas: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _erro = 'Não foi possível carregar suas plantas.';
        _carregando = false;
      });
    }
  }

  // ==================== CONSTRUIR TELA ====================

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final escuro = tema.brightness == Brightness.dark;

    final fundo = tema.scaffoldBackgroundColor;

    final texto = escuro ? Colors.white : verdeEscuro;

    final textoSecundario = escuro
        ? Colors.white70
        : verdeEscuro.withValues(alpha: 0.75);

    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(escuro),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _carregarPlantas,
                color: verdeAcao,
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
                      _buildGridPlantas(
                        escuro: escuro,
                        texto: texto,
                        textoSecundario: textoSecundario,
                      ),
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

  // ==================== CABEÇALHO ====================

  Widget _buildHeader(bool escuro) {
    return Container(
      width: double.infinity,
      color: escuro ? const Color(0xFF102A2E) : verdeEscuro,
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Meu Jardim',
                  style: TextStyle(
                    color: fundoBege,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _carregando
                      ? 'Carregando plantas...'
                      : '${_plantas.length} '
                          '${_plantas.length == 1 ? 'planta' : 'plantas'}'
                          ' · um cantinho de natureza',
                  style: const TextStyle(
                    color: fundoBege,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Botão para adicionar uma planta.
          Material(
            color: verdeAcao,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _abrirCadastroPlanta,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.add,
                  color: fundoBege,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ABRIR CADASTRO ====================

  Future<void> _abrirCadastroPlanta() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPlantScreen(),
      ),
    );

    if (!mounted) return;

    // Atualiza a lista somente quando o cadastro retorna true.
    if (resultado == true) {
      await _carregarPlantas();
    }
  }

  // ==================== GRID DE PLANTAS ====================

  Widget _buildGridPlantas({
    required bool escuro,
    required Color texto,
    required Color textoSecundario,
  }) {
    // Estado de carregamento.
    if (_carregando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Estado de erro.
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 52,
                color: escuro ? Colors.orangeAccent : Colors.redAccent,
              ),

              const SizedBox(height: 12),

              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: texto,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _carregarPlantas,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Estado vazio.
    if (_plantas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 48,
        ),
        child: Column(
          children: [
            Icon(
              Icons.eco_outlined,
              size: 64,
              color: escuro ? verdeBase : verdeEscuro,
            ),

            const SizedBox(height: 12),

            Text(
              'Seu jardim está vazio',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: texto,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Toque no botão + para adicionar sua primeira planta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoSecundario,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            
          ],
        ),
      );
    }

    // Lista dinâmica das plantas cadastradas.
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _plantas.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final planta = _plantas[index];

        final nome = planta['name']?.toString() ?? 'Planta';

        final especie = planta['species']?.toString() ?? '';

        final id = planta['id'];

        final imagemPath = planta['image_path']?.toString() ?? '';

        return _buildCardPlanta(
          id: id,
          nome: nome,
          cientifico: especie.isEmpty
              ? 'Espécie não informada'
              : especie,
          status: 'Cuidados cadastrados',
          corCard: index.isEven ? verdeChartreuse : verdeBase,
          corBadge: fundoBege,
          iconeBadge: Icons.eco_outlined,
          imagemUrl: imagemPath,
          escuro: escuro,
          texto: texto,
          textoSecundario: textoSecundario,
        );
      },
    );
  }

  // ==================== CARD DA PLANTA ====================

  Widget _buildCardPlanta({
    required dynamic id,
    required String nome,
    required String cientifico,
    required String status,
    required Color corCard,
    required Color corBadge,
    required IconData iconeBadge,
    required String imagemUrl,
    required bool escuro,
    required Color texto,
    required Color textoSecundario,
  }) {
    // Cores adaptadas ao tema.
    final corFundoCard = escuro
        ? const Color(0xFF1B383C)
        : corCard;

    final corBadgeAtual = escuro
        ? const Color(0xFF31564C)
        : corBadge;

    final corTextoBadge = escuro
        ? const Color(0xFFE1F0D9)
        : verdeEscuro;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: corFundoCard,
        borderRadius: BorderRadius.circular(16),
        border: escuro
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.07),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: escuro ? 0.12 : 0.08,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem ou ícone provisório da planta.
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _construirImagemPlanta(
                imagemPath: imagemUrl,
                escuro: escuro,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Nome popular e menu de opções.
          Row(
            children: [
              Expanded(
                child: Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: texto,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 150,
                ),
                icon: Icon(
                  Icons.more_vert,
                  color: textoSecundario,
                  size: 20,
                ),
                onSelected: (opcao) {
                  _selecionarOpcao(
                    opcao: opcao,
                    id: id,
                    nome: nome,
                  );
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'detalhes',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Ver detalhes'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Editar planta'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Espécie da planta.
          Text(
            cientifico,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textoSecundario,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 8),

          // Indicador informativo.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: corBadgeAtual,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconeBadge,
                  color: corTextoBadge,
                  size: 12,
                ),

                const SizedBox(width: 4),

                Flexible(
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: corTextoBadge,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== IMAGEM DA PLANTA ====================

  Widget _construirImagemPlanta({
    required String imagemPath,
    required bool escuro,
  }) {
    final corFundo = escuro
        ? const Color(0xFF294448)
        : Colors.black12;

    // Sem imagem cadastrada: mostra um ícone.
    if (imagemPath.isEmpty) {
      return Container(
        width: double.infinity,
        color: corFundo,
        child: Icon(
          Icons.eco,
          color: escuro ? verdeBase : verdeEscuro,
          size: 40,
        ),
      );
    }

    // URLs HTTP/HTTPS: tenta carregar uma imagem da internet.
    if (imagemPath.startsWith('https://') ||
        imagemPath.startsWith('http://')) {
      return Image.network(
        imagemPath,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagemAlternativa(corFundo, escuro);
        },
      );
    }

    // Caminhos locais ou assets não são interpretados
    // automaticamente, pois dependem de como a imagem foi salva.
    return _imagemAlternativa(corFundo, escuro);
  }

  Widget _imagemAlternativa(Color corFundo, bool escuro) {
    return Container(
      width: double.infinity,
      color: corFundo,
      child: Icon(
        Icons.eco,
        color: escuro ? verdeBase : verdeEscuro,
        size: 40,
      ),
    );
  }

  // ==================== OPÇÕES DO CARD ====================

  void _selecionarOpcao({
    required String opcao,
    required dynamic id,
    required String nome,
  }) {
    String mensagem;

    switch (opcao) {
      case 'detalhes':
        mensagem = 'A tela de detalhes de $nome ainda precisa ser implementada.';
        break;

      case 'editar':
        mensagem = 'A edição de $nome ainda precisa ser implementada.';
        break;

      default:
        return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}