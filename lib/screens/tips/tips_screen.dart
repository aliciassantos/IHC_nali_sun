
import 'package:flutter/material.dart';

import '../../models/article_model.dart';
import '../../repositories/article_repository.dart';
import 'article_details_screen.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  // Paleta de cores do NaliSun.
  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeAcao = Color(0xFF258A60);
  static const Color textoCardEscuro = Color(0xFF392E0E);

  // =========================================================
  // NAVEGAÇÃO PARA O ARTIGO COMPLETO
  // =========================================================

  void _abrirArtigo(BuildContext context, ArticleModel artigo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailsScreen(
          article: artigo,
        ),
      ),
    );
  }

  // =========================================================
  // CONSTRUIR TELA
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final escuro = tema.brightness == Brightness.dark;

    // Carrega somente os artigos estáticos do repositório.
    final List<ArticleModel> artigos =
        ArticleRepository.getGeneralTips();

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(escuro),

            Expanded(
              child: artigos.isEmpty
                  ? _buildListaVazia(escuro)
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      itemCount: artigos.length,
                      itemBuilder: (context, index) {
                        final artigo = artigos[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildCardDica(
                            context: context,
                            artigo: artigo,
                            corBadge: index.isEven
                                ? verdeAcao
                                : textoCardEscuro,
                            escuro: escuro,
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

  Widget _buildHeader(bool escuro) {
    return Container(
      width: double.infinity,
      color: escuro
          ? const Color(0xFF102A2E)
          : verdeEscuro,
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Dicas para Florescer',
            style: TextStyle(
              color: fundoBege,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Pequenos saberes, plantas mais felizes.',
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

  // =========================================================
  // CARD DE DICA
  // =========================================================

  Widget _buildCardDica({
    required BuildContext context,
    required ArticleModel artigo,
    required Color corBadge,
    required bool escuro,
  }) {
    final caminhoImagem =
        artigo.imagem?.trim().isNotEmpty == true
            ? artigo.imagem!.trim()
            : 'assets/img/plantinha1.jpg';

    final imagemOnline =
        caminhoImagem.startsWith('https://') ||
        caminhoImagem.startsWith('http://');

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        // Ao tocar no card, abre o artigo correspondente.
        onTap: () => _abrirArtigo(context, artigo),

        child: Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            color: escuro
                ? const Color(0xFF1B383C)
                : verdeEscuro,
            borderRadius: BorderRadius.circular(16),
            border: escuro
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: escuro ? 0.16 : 0.08,
                ),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // IMAGEM DE FUNDO.
                Positioned.fill(
                  child: imagemOnline
                      ? Image.network(
                          caminhoImagem,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _imagemPadrao(escuro);
                          },
                        )
                      : Image.asset(
                          caminhoImagem,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _imagemPadrao(escuro);
                          },
                        ),
                ),

                // GRADIENTE PARA FACILITAR A LEITURA.
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(
                            alpha: escuro ? 0.25 : 0.15,
                          ),
                          (escuro
                                  ? const Color(0xFF102A2E)
                                  : verdeEscuro)
                              .withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                  ),
                ),

                // CONTEÚDO DO CARD.
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Categoria e tempo estimado de leitura.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: corBadge,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              artigo.categoria,
                              style: const TextStyle(
                                color: fundoBege,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                            ),

                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              width: 1,
                              height: 10,
                              color: fundoBege,
                            ),

                            // CÁLCULO AUTOMÁTICO DO TEMPO DE LEITURA.
                            Text(
                              artigo.tempoLeituraFormatado,
                              style: const TextStyle(
                                color: fundoBege,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // TÍTULO.
                      Text(
                        artigo.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // RESUMO.
                      Text(
                        artigo.resumo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // INDICADOR DE NAVEGAÇÃO.
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Ler mais',
                            style: TextStyle(
                              color: fundoBege,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: fundoBege,
                            size: 13,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // IMAGEM PADRÃO
  // =========================================================

  Widget _imagemPadrao(bool escuro) {
    return Container(
      color: escuro
          ? const Color(0xFF294448)
          : verdeEscuro,
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book,
        color: fundoBege,
        size: 48,
      ),
    );
  }

  // =========================================================
  // LISTA VAZIA
  // =========================================================

  Widget _buildListaVazia(bool escuro) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              color: verdeAcao,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma dica disponível no momento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: escuro ? fundoBege : verdeEscuro,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
