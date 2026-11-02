
import 'package:flutter/material.dart';

import '../../models/article_model.dart';

class ArticleDetailsScreen extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailsScreen({
    super.key,
    required this.article,
  });

  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeAcao = Color(0xFF258A60);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final escuro = tema.brightness == Brightness.dark;

    // Separa o conteúdo em parágrafos.
    final paragrafos = article.conteudo
        .trim()
        .split(RegExp(r'\n\s*\n'))
        .where((paragrafo) => paragrafo.trim().isNotEmpty)
        .toList();

    final imagem = article.imagem?.trim() ?? '';

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: escuro
            ? const Color(0xFF102A2E)
            : verdeEscuro,
        foregroundColor: fundoBege,
        elevation: 0,
        title: const Text(
          'Dicas para Florescer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // IMAGEM DO ARTIGO
            // ==========================================

            SizedBox(
              height: 230,
              width: double.infinity,
              child: imagem.isEmpty
                  ? _imagemPadrao()
                  : imagem.startsWith('http')
                      ? Image.network(
                          imagem,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _imagemPadrao();
                          },
                        )
                      : Image.asset(
                          imagem,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _imagemPadrao();
                          },
                        ),
            ),

            // ==========================================
            // CONTEÚDO DO ARTIGO
            // ==========================================

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoria.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: verdeAcao,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      article.categoria,
                      style: const TextStyle(
                        color: fundoBege,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Título.
                  Text(
                    article.titulo,
                    style: TextStyle(
                      color: escuro ? fundoBege : verdeEscuro,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tempo de leitura.
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        color: verdeAcao,
                        size: 19,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        article.tempoLeituraFormatado,
                        style: TextStyle(
                          color: escuro
                              ? Colors.white70
                              : Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Resumo.
                  Text(
                    article.resumo,
                    style: TextStyle(
                      color: escuro ? Colors.white : verdeEscuro,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Divider(
                    color: escuro
                        ? Colors.white24
                        : verdeEscuro.withValues(alpha: 0.15),
                  ),

                  const SizedBox(height: 20),

                  // ======================================
                  // TEXTO COMPLETO
                  // ======================================

                  ...paragrafos.map((paragrafo) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text(
                        paragrafo.trim(),
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: escuro
                              ? Colors.white70
                              : const Color(0xFF454545),
                          fontSize: 15,
                          height: 1.8,
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Imagem alternativa.
  Widget _imagemPadrao() {
    return Container(
      width: double.infinity,
      color: verdeEscuro,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_florist,
        color: fundoBege,
        size: 65,
      ),
    );
  }
}
