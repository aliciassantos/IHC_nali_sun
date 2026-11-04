import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/plant_provider.dart';

class PlantDetailsScreen extends StatefulWidget {
  final String plantId;

  const PlantDetailsScreen({
    super.key,
    required this.plantId,
  });

  @override
  State<PlantDetailsScreen> createState() =>
      _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  // ==================== PALETA DE CORES ====================

  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeMedio = Color(0xFF258A60);
  static const Color verdeFolha = Color(0xFF5AA68C);
  static const Color verdeClaro = Color(0xFF81B380);
  static const Color amareloVerde = Color(0xFFA7BF73);
  static const Color amareloCreme = Color(0xFFD6D578);
  static const Color fundoAmarelado = Color(0xFFFBE4AE);

  // ==================== ESTADO DA TELA ====================

  Map<String, dynamic>? planta;

  bool carregando = true;
  bool processandoRega = false;
  bool processandoExclusao = false;

  // ==================== CICLO DE VIDA ====================

  @override
  void initState() {
    super.initState();
    _carregarPlanta();
  }

  // ==================== CARREGAR PLANTA ====================

  Future<void> _carregarPlanta() async {
    final id = int.tryParse(widget.plantId);

    if (id == null) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      return;
    }

    final provider = context.read<PlantProvider>();

    var resultado = provider.buscarPlanta(id);

    if (resultado == null) {
      await provider.carregarPlantas();
      resultado = provider.buscarPlanta(id);
    }

    if (!mounted) return;

    setState(() {
      planta = resultado;
      carregando = false;
    });
  }

  // ==================== REGISTRAR REGA ====================

  Future<void> _regarAgora() async {
    if (processandoRega || planta == null) return;

    setState(() {
      processandoRega = true;
    });

    try {
      final id = int.parse(widget.plantId);

      await context.read<PlantProvider>().registrarRega(id);

      if (!mounted) return;

      await _carregarPlanta();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rega registrada com sucesso! 💧'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível registrar a rega: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          processandoRega = false;
        });
      }
    }
  }

  // ==================== EXCLUIR PLANTA ====================

  Future<void> _excluirPlanta() async {
    if (planta == null || processandoExclusao) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir planta?'),
          content: Text(
            'Deseja realmente excluir ${planta!['name']}? '
            'Essa ação não poderá ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() {
      processandoExclusao = true;
    });

    try {
      await context.read<PlantProvider>().excluirPlanta(
        int.parse(widget.plantId),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        processandoExclusao = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir planta: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==================== CONSTRUIR TELA ====================

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        backgroundColor: fundoAmarelado,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (planta == null) {
      return Scaffold(
        backgroundColor: fundoAmarelado,
        appBar: AppBar(
          backgroundColor: verdeEscuro,
          title: const Text(
            'Detalhes da planta',
            style: TextStyle(color: fundoAmarelado),
          ),
          iconTheme: const IconThemeData(
            color: fundoAmarelado,
          ),
        ),
        body: const Center(
          child: Text('Planta não encontrada.'),
        ),
      );
    }

    final nome = planta!['name']?.toString() ?? 'Planta';

    final especie =
        planta!['species']?.toString() ?? 'Espécie não informada';

    final frequencia =
        (planta!['watering_frequency_days'] as num?)?.toInt() ?? 1;

    final luminosidade =
        planta!['luminosity']?.toString() ?? 'Não informada';

    final imagem =
        planta!['image_path']?.toString() ?? '';

    return Scaffold(
      backgroundColor: fundoAmarelado,

      // ==================== APP BAR ====================

      appBar: AppBar(
        backgroundColor: verdeEscuro,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: fundoAmarelado,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: fundoAmarelado,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              especie,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: fundoAmarelado,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: amareloVerde,
              radius: 18,
              child: Icon(
                Icons.edit_outlined,
                size: 18,
                color: verdeEscuro,
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'A edição da planta ainda será implementada.',
                  ),
                ),
              );
            },
          ),

          IconButton(
            icon: const CircleAvatar(
              backgroundColor: verdeFolha,
              radius: 18,
              child: Icon(
                Icons.delete_outline,
                size: 18,
                color: fundoAmarelado,
              ),
            ),
            onPressed: processandoExclusao
                ? null
                : _excluirPlanta,
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ==================== CONTEÚDO ====================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================== IMAGEM ====================

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imagem.isNotEmpty
                  ? Image.network(
                      imagem,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagemAlternativa();
                      },
                    )
                  : _imagemAlternativa(),
            ),

            const SizedBox(height: 16),

            // ==================== REGA E LUMINOSIDADE ====================

            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.water_drop_outlined,
                    title: 'A cada $frequencia '
                        '${frequencia == 1 ? 'dia' : 'dias'}',
                    subtitle: _textoProximaRega(frequencia),
                    gradientColors: [
                      verdeFolha,
                      verdeClaro,
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.wb_sunny_outlined,
                    title: luminosidade,
                    subtitle: 'Luminosidade',
                    gradientColors: [
                      amareloCreme,
                      amareloVerde,
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================== BOTÃO REGAR ====================

            ElevatedButton(
              onPressed: processandoRega ? null : _regarAgora,
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeMedio,
                foregroundColor: fundoAmarelado,
                disabledBackgroundColor: verdeMedio.withValues(
                  alpha: 0.6,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (processandoRega)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: fundoAmarelado,
                      ),
                    )
                  else
                    const Text(
                      '💦 ',
                      style: TextStyle(fontSize: 16),
                    ),

                  const SizedBox(width: 4),

                  Text(
                    processandoRega
                        ? 'Registrando...'
                        : 'Regar Agora',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================== ASSIDUIDADE ====================

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    amareloCreme,
                    amareloVerde,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(
                            Icons.stars_outlined,
                            size: 20,
                            color: verdeEscuro,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Assiduidade',
                            style: TextStyle(
                              color: verdeEscuro,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        '92%',
                        style: TextStyle(
                          color: verdeEscuro,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: const LinearProgressIndicator(
                      value: 0.92,
                      minHeight: 8,
                      backgroundColor: amareloCreme,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        verdeMedio,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Uma rotina gentil, um jardim saudável.',
                    style: TextStyle(
                      color: verdeEscuro,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================== ESTATÍSTICAS ====================

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_today_outlined,
                    value: '12',
                    label: 'Total de regas no mês',
                    gradientColors: [
                      verdeFolha,
                      verdeClaro,
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildStatCard(
                    icon: Icons.eco_outlined,
                    value: '8',
                    label: 'Total de dias de cultivo',
                    gradientColors: [
                      amareloVerde,
                      verdeClaro,
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== IMAGEM ALTERNATIVA ====================

  Widget _imagemAlternativa() {
    return Container(
      height: 180,
      width: double.infinity,
      color: verdeFolha.withValues(alpha: 0.3),
      child: const Icon(
        Icons.eco,
        size: 48,
        color: verdeEscuro,
      ),
    );
  }

  // ==================== PRÓXIMA REGA ====================

  String _textoProximaRega(int frequencia) {
    final ultimaRegaString = planta!['last_watered_at']?.toString();
    final cadastroString = planta!['created_at']?.toString();

    final referencia = DateTime.tryParse(
      ultimaRegaString ?? '',
    ) ?? DateTime.tryParse(
      cadastroString ?? '',
    );

    if (referencia == null) {
      return 'Data não disponível';
    }

    final proximaRega = referencia.add(
      Duration(days: frequencia),
    );

    final hoje = DateTime.now();

    final hojeData = DateTime(
      hoje.year,
      hoje.month,
      hoje.day,
    );

    final proximaData = DateTime(
      proximaRega.year,
      proximaRega.month,
      proximaRega.day,
    );

    final diferenca = proximaData.difference(hojeData).inDays;

    if (diferenca < 0) {
      return 'Atrasada há ${diferenca.abs()} '
          '${diferenca.abs() == 1 ? 'dia' : 'dias'}';
    }

    if (diferenca == 0) {
      return 'Próxima: hoje';
    }

    if (diferenca == 1) {
      return 'Próxima: amanhã';
    }

    return 'Próxima em $diferenca dias';
  }

  // ==================== CARD DE INFORMAÇÃO ====================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: verdeEscuro,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: verdeEscuro,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            style: const TextStyle(
              color: verdeEscuro,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARD DE ESTATÍSTICAS ====================

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: verdeEscuro,
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              color: verdeEscuro,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: const TextStyle(
              color: verdeEscuro,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}