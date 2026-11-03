// profile_screen.dart
// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Paleta original do Nali-Sun
  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeBase = Color(0xFF81B380);
  static const Color verdeAvisoCard = Color(0xFF5AA68C);
  static const Color cardOpcoesFundo = Color(0xFFDACB8A);
  bool _aparenciaExpandida = false;
  bool _sobreEstufaExpandida = false;
  bool _notificacoesExpandida = false;
  bool _lembretesRega = true;
  bool _dicasJardinagem = true;
  bool _avisosCuidado = true;
  bool _carregandoNotificacoes = true;
  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
  }

  // ==================== CARREGAR NOTIFICAÇÕES ====================
  Future<void> _carregarNotificacoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _lembretesRega = prefs.getBool('nalisun_lembretes_rega') ?? true;
        _dicasJardinagem = prefs.getBool('nalisun_dicas_ativas') ?? true;
        _avisosCuidado = prefs.getBool('nalisun_avisos_cuidado') ?? true;
        _carregandoNotificacoes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregandoNotificacoes = false;
      });
    }
  }

  // ==================== SALVAR NOTIFICAÇÕES ====================
  Future<void> _salvarLembretesRega(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nalisun_lembretes_rega', valor);
    if (!mounted) return;
    setState(() {
      _lembretesRega = valor;
    });
  }

  Future<void> _salvarDicas(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nalisun_dicas_ativas', valor);
    if (!mounted) return;
    setState(() {
      _dicasJardinagem = valor;
    });
  }

  Future<void> _salvarAvisos(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nalisun_avisos_cuidado', valor);
    if (!mounted) return;
    setState(() {
      _avisosCuidado = valor;
    });
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: verdeEscuro,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==================== TELA PRINCIPAL ====================
  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().currentUser;
    final tema = context.watch<ThemeProvider>();
    final cores = Theme.of(context).colorScheme;
    final escuro = tema.isDarkMode;
    return Scaffold(
      backgroundColor: escuro ? cores.surface : fundoBege,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(escuro: escuro),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCardUsuario(
                      nome: usuario?.name ?? 'Usuário',
                      dataCadastro: usuario?.createdAt,
                      avatarPath: usuario?.avatarPath,
                      escuro: escuro,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Minha conta',
                      style: TextStyle(
                        color: escuro ? cores.onSurface : verdeEscuro,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContainerOpcoes(
                      nome: usuario?.name ?? 'Usuário',
                      email: usuario?.email ?? '',
                      escuro: escuro,
                      tema: tema,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EDIÇÃO DA CONTA ====================

  Future<void> _abrirEdicaoConta() async {
    final usuario = context.read<AuthProvider>().currentUser;

    if (usuario == null ||
        Supabase.instance.client.auth.currentUser?.id != usuario.id) {
      _mostrarMensagem('Faça login para editar sua conta.');
      return;
    }

    // Aguarda o BottomSheet retornar a opção escolhida.
    final acao = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final escuro = Theme.of(sheetContext).brightness == Brightness.dark;

        final corTexto = escuro ? Colors.white : verdeEscuro;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Editar conta',
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Alterar nome'),
                  onTap: () {
                    Navigator.pop(sheetContext, 'nome');
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Alterar foto de perfil'),
                  onTap: () {
                    Navigator.pop(sheetContext, 'foto');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    // O BottomSheet já terminou de fechar.
    if (!mounted || acao == null) return;

    // Só agora abre a próxima operação.
    switch (acao) {
      case 'nome':
        await _editarNome();
        break;

      case 'foto':
        await _alterarFoto();
        break;
    }
  }

  Future<void> _editarNome() async {
    final authProvider = context.read<AuthProvider>();
    final usuario = authProvider.currentUser;

    if (usuario == null ||
        Supabase.instance.client.auth.currentUser?.id != usuario.id) {
      _mostrarMensagem('Faça login para alterar seu nome.');
      return;
    }

    String novoNome = usuario.name;

    final resultado = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Alterar nome'),
          content: TextFormField(
            initialValue: usuario.name,
            autofocus: true,
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nome',
              hintText: 'Digite seu nome',
            ),
            onChanged: (valor) {
              novoNome = valor.trim();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, novoNome);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (resultado == null || !mounted) return;

    if (resultado.length < 2) {
      _mostrarMensagem('O nome deve ter pelo menos 2 caracteres.');
      return;
    }

    try {
      await authProvider.updateName(resultado);

      if (!mounted) return;

      _mostrarMensagem('Nome atualizado com sucesso.');
    } catch (e) {
      if (!mounted) return;

      _mostrarMensagem('Não foi possível atualizar o nome: $e');
    }
  }

  Future<void> _alterarFoto() async {
    final authProvider = context.read<AuthProvider>();
    final usuario = authProvider.currentUser;
    final cliente = Supabase.instance.client;

    // A foto só pode ser alterada por uma conta autenticada.
    if (usuario == null || cliente.auth.currentUser?.id != usuario.id) {
      _mostrarMensagem('Faça login para adicionar uma foto de perfil.');
      return;
    }

    try {
      final imagem = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (imagem == null || !mounted) return;

      final bytes = await imagem.readAsBytes();
      if (bytes.isEmpty) {
        _mostrarMensagem('Não foi possível ler a imagem selecionada.');
        return;
      }

      final extensaoOriginal = imagem.name.contains('.')
          ? imagem.name.split('.').last.toLowerCase()
          : 'jpg';
      final extensao = ['jpg', 'jpeg', 'png', 'webp'].contains(extensaoOriginal)
          ? extensaoOriginal
          : 'jpg';

      final contentType = switch (extensao) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };

      // O caminho exclusivo evita reutilização de uma foto antiga em cache.
      final caminho =
          '${usuario.id}/${DateTime.now().millisecondsSinceEpoch}.$extensao';

      await cliente.storage
          .from('avatars')
          .uploadBinary(
            caminho,
            bytes,
            fileOptions: FileOptions(upsert: false, contentType: contentType),
          );

      await authProvider.updateAvatar(caminho);

      if (!mounted) return;
      _mostrarMensagem('Foto de perfil atualizada com sucesso.');
    } on StorageException catch (e) {
      if (!mounted) return;
      _mostrarMensagem('Erro ao enviar a foto: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem('Não foi possível atualizar a foto: $e');
    }
  }

  // ==================== HEADER ====================
  Widget _buildHeader({required bool escuro}) {
    return Container(
      width: double.infinity,
      color: escuro ? const Color(0xFF102A2E) : verdeEscuro,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meu cantinho',
            style: TextStyle(
              color: fundoBege,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Uma rotina de cuidado, do seu jeito.',
            style: TextStyle(
              color: fundoBege,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARD DO USUÁRIO ====================
  Widget _buildCardUsuario({
    required String nome,
    required DateTime? dataCadastro,
    required String? avatarPath,
    required bool escuro,
  }) {
    final imagemUrl = avatarPath == null || avatarPath.isEmpty
        ? null
        : Supabase.instance.client.storage
              .from('avatars')
              .getPublicUrl(avatarPath);

    final dataFormatada = dataCadastro == null
        ? 'Bem-vindo ao Nali-Sun!'
        : 'Cultivando desde '
              '${_nomeMes(dataCadastro.month)} de ${dataCadastro.year}';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: escuro
              ? const [Color(0xFF25484A), Color(0xFF1B393D)]
              : const [verdeAvisoCard, verdeBase],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _mostrarFotoAmpliada(imagemUrl),
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: escuro ? const Color(0xFF102A2E) : fundoBege,
                border: Border.all(
                  color: escuro ? verdeBase : verdeEscuro,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: imagemUrl == null
                    ? Icon(
                        Icons.person,
                        size: 48,
                        color: escuro ? fundoBege : verdeEscuro,
                      )
                    : Image.network(
                        imagemUrl,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 48,
                            color: escuro ? fundoBege : verdeEscuro,
                          );
                        },
                      ),
              ),
            ),
          ),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: escuro ? fundoBege : verdeEscuro,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dataFormatada,
                  style: TextStyle(
                    color: escuro ? Colors.white70 : verdeEscuro,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '🌿 Seu espaço de cuidado',
                  style: TextStyle(
                    color: escuro ? fundoBege : verdeEscuro,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _nomeMes(int mes) {
    const meses = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return meses[mes - 1];
  }

  // ==================== OPÇÕES DO PERFIL ====================
  Widget _buildContainerOpcoes({
    required String nome,
    required String email,
    required bool escuro,
    required ThemeProvider tema,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: escuro ? const Color(0xFF25484A) : cardOpcoesFundo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // CONTA
          _buildItemOpcao(
            icone: Icons.person_outline,
            titulo: 'Conta',
            subtitulo: '$nome · $email',
            mostrarDivisor: true,
            escuro: escuro,
            onTap: _abrirEdicaoConta,
          ),
          // NOTIFICAÇÕES
          _buildItemExpansivel(
            icone: Icons.notifications_none,
            titulo: 'Notificações',
            subtitulo: _carregandoNotificacoes
                ? 'Carregando configurações...'
                : _lembretesRega
                ? 'Lembretes de rega ativados'
                : 'Lembretes de rega desativados',
            expandido: _notificacoesExpandida,
            escuro: escuro,
            onTap: () {
              setState(() {
                _notificacoesExpandida = !_notificacoesExpandida;
              });
            },
            conteudo: _carregandoNotificacoes
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _buildConteudoNotificacoes(escuro: escuro),
          ),
          // APARÊNCIA
          _buildItemAparencia(tema: tema, escuro: escuro),
          // SOBRE O APLICATIVO
          _buildItemSobreEstufa(escuro: escuro),
          // SAIR DA CONTA
          _buildItemOpcao(
            icone: Icons.logout,
            titulo: 'Sair da conta',
            subtitulo: 'Desconectar deste dispositivo',
            mostrarDivisor: false,
            escuro: escuro,
            corEspecial: Colors.red.shade700,
            onTap: _confirmarLogout,
          ),
        ],
      ),
    );
  }

  // ==================== ITEM EXPANSÍVEL ====================
  Widget _buildItemExpansivel({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required bool expandido,
    required bool escuro,
    required VoidCallback onTap,
    required Widget conteudo,
  }) {
    final cores = Theme.of(context).colorScheme;
    final corTexto = escuro ? cores.onSurface : verdeEscuro;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: verdeBase.withValues(alpha: 0.4), width: 1),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Icon(icone, color: corTexto, size: 22),
            title: Text(
              titulo,
              style: TextStyle(
                color: corTexto,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              subtitulo,
              style: TextStyle(
                color: escuro ? Colors.white70 : verdeEscuro,
                fontSize: 12,
              ),
            ),
            trailing: AnimatedRotation(
              turns: expandido ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.chevron_right, color: corTexto, size: 22),
            ),
            onTap: onTap,
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
            crossFadeState: expandido
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: conteudo,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CONTEÚDO DAS NOTIFICAÇÕES ====================
  Widget _buildConteudoNotificacoes({required bool escuro}) {
    final corTexto = escuro ? Colors.white : verdeEscuro;
    return Column(
      children: [
        _buildInterruptor(
          icone: Icons.water_drop_outlined,
          titulo: 'Lembretes de rega',
          subtitulo: 'Avisos para lembrar de regar as plantas.',
          valor: _lembretesRega,
          corTexto: corTexto,
          onChanged: _salvarLembretesRega,
        ),
        _buildInterruptor(
          icone: Icons.spa_outlined,
          titulo: 'Dicas de jardinagem',
          subtitulo: 'Preferência para dicas e recomendações.',
          valor: _dicasJardinagem,
          corTexto: corTexto,
          onChanged: _salvarDicas,
        ),
        _buildInterruptor(
          icone: Icons.notifications_active_outlined,
          titulo: 'Avisos sobre cuidados',
          subtitulo: 'Avisos relacionados às plantas.',
          valor: _avisosCuidado,
          corTexto: corTexto,
          onChanged: _salvarAvisos,
        ),
        const SizedBox(height: 8),
        Text(
          'Essas opções salvam suas preferências. '
          'O envio de notificações reais ainda precisa ser implementado.',
          style: TextStyle(
            color: corTexto.withValues(alpha: 0.75),
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ==================== INTERRUPTORES ====================
  Widget _buildInterruptor({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required bool valor,
    required Color corTexto,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icone, color: corTexto, size: 22),
      title: Text(
        titulo,
        style: TextStyle(
          color: corTexto,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: TextStyle(color: corTexto.withValues(alpha: 0.75), fontSize: 11),
      ),
      value: valor,
      activeThumbColor: verdeAvisoCard,
      onChanged: onChanged,
    );
  }

  // ==================== ITEM NORMAL DA LISTA ====================
  Widget _buildItemOpcao({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required bool mostrarDivisor,
    required bool escuro,
    required VoidCallback onTap,
    Color? corEspecial,
  }) {
    final cores = Theme.of(context).colorScheme;
    final corTexto = corEspecial ?? (escuro ? cores.onSurface : verdeEscuro);
    return Container(
      decoration: mostrarDivisor
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: verdeBase.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            )
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icone, color: corTexto, size: 22),
        title: Text(
          titulo,
          style: TextStyle(
            color: corTexto,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: TextStyle(
            color: escuro ? Colors.white70 : verdeEscuro,
            fontSize: 12,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: corTexto, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _mostrarFotoAmpliada(String? fotoUrl) {
    if (fotoUrl == null || fotoUrl.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: true, // Fecha ao clicar fora da foto
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(20),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(dialogContext),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: ClipOval(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Image.network(
                      fotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: fundoBege,
                          child: const Icon(
                            Icons.broken_image,
                            color: verdeEscuro,
                            size: 60,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== APARÊNCIA EXPANSÍVEL ====================
  Widget _buildItemAparencia({
    required ThemeProvider tema,
    required bool escuro,
  }) {
    final cores = Theme.of(context).colorScheme;
    final corTexto = escuro ? cores.onSurface : verdeEscuro;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: verdeBase.withValues(alpha: 0.4), width: 1),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Icon(Icons.palette_outlined, color: corTexto, size: 22),
            title: Text(
              'Aparência',
              style: TextStyle(
                color: corTexto,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              tema.isDarkMode ? 'Tema escuro ativado' : 'Tema claro ativado',
              style: TextStyle(
                color: escuro ? Colors.white70 : verdeEscuro,
                fontSize: 12,
              ),
            ),
            trailing: AnimatedRotation(
              turns: _aparenciaExpandida ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.chevron_right, color: corTexto, size: 22),
            ),
            onTap: () {
              setState(() {
                _aparenciaExpandida = !_aparenciaExpandida;
              });
            },
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
            crossFadeState: _aparenciaExpandida
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: [
                  _buildOpcaoTema(
                    icone: Icons.wb_sunny_outlined,
                    titulo: 'Claro',
                    selecionado: !tema.isDarkMode,
                    escuro: escuro,
                    onTap: () async {
                      await tema.setDarkMode(false);
                    },
                  ),
                  _buildOpcaoTema(
                    icone: Icons.nightlight_outlined,
                    titulo: 'Escuro',
                    selecionado: tema.isDarkMode,
                    escuro: escuro,
                    onTap: () async {
                      await tema.setDarkMode(true);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== OPÇÃO DE TEMA ====================
  Widget _buildOpcaoTema({
    required IconData icone,
    required String titulo,
    required bool selecionado,
    required bool escuro,
    required VoidCallback onTap,
  }) {
    final corTexto = escuro ? Colors.white : verdeEscuro;
    final corIcone = escuro ? fundoBege : verdeEscuro;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Row(
          children: [
            Icon(icone, color: corIcone, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  color: corTexto,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              selecionado ? Icons.check_circle_outline : Icons.circle,
              color: selecionado
                  ? verdeBase
                  : (escuro ? Colors.white70 : Colors.blueGrey.shade300),
              size: selecionado ? 18 : 20,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SOBRE MINHA ESTUFA ====================
  Widget _buildItemSobreEstufa({required bool escuro}) {
    final cores = Theme.of(context).colorScheme;
    final corTexto = escuro ? cores.onSurface : verdeEscuro;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: verdeBase.withValues(alpha: 0.4), width: 1),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Icon(Icons.info_outline, color: corTexto, size: 22),
            title: Text(
              'Sobre Minha Estufa',
              style: TextStyle(
                color: corTexto,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Versão 1.0 · cuidado que aproxima',
              style: TextStyle(
                color: escuro ? Colors.white70 : verdeEscuro,
                fontSize: 12,
              ),
            ),
            trailing: AnimatedRotation(
              turns: _sobreEstufaExpandida ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.chevron_right, color: corTexto, size: 22),
            ),
            onTap: () {
              setState(() {
                _sobreEstufaExpandida = !_sobreEstufaExpandida;
              });
            },
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
            crossFadeState: _sobreEstufaExpandida
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nali-Sun',
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Um espaço para acompanhar suas plantas, '
                    'organizar os cuidados e cultivar sua rotina '
                    'com mais carinho.',
                    style: TextStyle(
                      color: escuro ? Colors.white70 : verdeEscuro,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _linhaInformacao('Versão', '1.0', escuro: escuro),
                  _linhaInformacao('Aplicativo', 'Nali-Sun', escuro: escuro),
                  _linhaInformacao(
                    'Mensagem',
                    'Cuidado que aproxima.',
                    escuro: escuro,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== INFORMAÇÕES ====================
  Widget _linhaInformacao(String titulo, String valor, {required bool escuro}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              titulo,
              style: TextStyle(
                color: escuro ? Colors.white70 : verdeEscuro,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                color: escuro ? Colors.white : verdeEscuro,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== LOGOUT ====================
  Future<void> _confirmarLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Sair da conta?'),
          content: const Text(
            'Você precisará entrar novamente para acessar suas plantas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (confirmar != true || !mounted) return;
    try {
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível sair da conta. Tente novamente.'),
        ),
      );
    }
  }
}
