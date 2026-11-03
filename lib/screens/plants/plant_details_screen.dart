import 'package:flutter/material.dart';

class PlantDetailsScreen extends StatelessWidget {
  final String plantId;

  const PlantDetailsScreen({
    super.key,
    required this.plantId,
  });

  // Cores do padrão visual do aplicativo
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeMedio = Color(0xFF258A60);
  static const Color verdeFolha = Color(0xFF5AA68C);
  static const Color verdeClaro = Color(0xFF81B380);
  static const Color amareloVerde = Color(0xFFA7BF73);
  static const Color amareloCreme = Color(0xFFD6D578);
  static const Color fundoAmarelado = Color(0xFFFBE4AE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoAmarelado,
      appBar: AppBar(
        backgroundColor: verdeEscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: fundoAmarelado),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Samambaia',
              style: TextStyle(
                color: fundoAmarelado,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Nephrolepis exaltata',
              style: TextStyle(
                color: fundoAmarelado,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: amareloVerde,
              radius: 18,
              child: const Icon(Icons.edit_outlined, size: 18, color: verdeEscuro),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundColor: verdeFolha,
              radius: 18,
              child: const Icon(Icons.delete_outline, size: 18, color: fundoAmarelado),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem da Planta
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://placehold.co/362x183',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: verdeFolha.withOpacity(0.3),
                  child: const Icon(Icons.eco, size: 48, color: verdeEscuro),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rega e Luminosidade (Cards Lado a Lado)
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.water_drop_outlined,
                    title: 'A cada 2 dias',
                    subtitle: 'Próxima: HOJE, 18h',
                    gradientColors: [verdeFolha, verdeClaro],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Luz indireta',
                    subtitle: 'Meia-sombra',
                    gradientColors: [amareloCreme, amareloVerde],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botão Regar Agora
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeMedio,
                foregroundColor: fundoAmarelado,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('💦 ', style: TextStyle(fontSize: 16)),
                  Text(
                    'Regar Agora',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card de Assiduidade
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [amareloCreme, amareloVerde],
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
                          Icon(Icons.stars_outlined, size: 20, color: verdeEscuro),
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
                    child: LinearProgressIndicator(
                      value: 0.92,
                      minHeight: 8,
                      backgroundColor: amareloCreme,
                      valueColor: const AlwaysStoppedAnimation<Color>(verdeMedio),
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

            // Estatísticas (Regas e Dias de Cultivo)
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_today_outlined,
                    value: '12',
                    label: 'Total de regas no mês',
                    gradientColors: [verdeFolha, verdeClaro],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.eco_outlined,
                    value: '8',
                    label: 'Total de dias de cultivo',
                    gradientColors: [amareloVerde, verdeClaro],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para os cards de rega/luz
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
          Icon(icon, size: 22, color: verdeEscuro),
          const SizedBox(height: 8),
          Text(
            title,
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

  // Widget auxiliar para as métricas numéricas
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
          Icon(icon, size: 22, color: verdeEscuro),
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