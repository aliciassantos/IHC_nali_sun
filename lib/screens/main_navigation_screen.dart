// Tela contendo a BottomNavigationBar e IndexedStack
// Navegação principal do footer

import 'package:flutter/material.dart';

import 'package:nali_sun_app/screens/home/home_screen.dart';
import 'package:nali_sun_app/screens/plants/plants_screen.dart';
import 'package:nali_sun_app/screens/calendar/calendar_screen.dart';
import 'package:nali_sun_app/screens/tips/tips_screen.dart';
import 'package:nali_sun_app/screens/profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Índice da aba selecionada.
  int _indiceAtual = 0;

  // Chave para acessar os métodos públicos da Home.
  final GlobalKey<HomeScreenState> _homeKey =
      GlobalKey<HomeScreenState>();

  // Todas as telas do aplicativo.
  // A ordem deve ser mantida para corresponder aos índices.
  late final List<Widget> _telas = [
    HomeScreen(
      key: _homeKey,
      onNavigateToTab: _selecionarAba,
    ),
    const MyGardenScreen(),
    const CalendarScreen(),
    const TipsScreen(),
    const ProfileScreen(),
  ];

  // =========================================================
  // NAVEGAÇÃO ENTRE AS ABAS
  // =========================================================

  void _selecionarAba(int index) {
    if (index < 0 || index >= _telas.length) return;

    setState(() {
      _indiceAtual = index;
    });

    // Quando o usuário retorna à Home,
    // atualiza os dados das plantas.
    if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _homeKey.currentState?.atualizarPlantas();
      });
    }
  }

  // =========================================================
  // BARRA DE NAVEGAÇÃO INFERIOR
  // =========================================================

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _indiceAtual,
      onTap: _selecionarAba,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF0B3740),
      selectedItemColor: const Color(0xFFFBE4AE),
      unselectedItemColor: const Color(0xFFDACB8A),
      selectedFontSize: 12,
      unselectedFontSize: 11,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.eco_outlined),
          activeIcon: Icon(Icons.eco),
          label: 'Plantas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Calendário',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Dicas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  // =========================================================
  // CONSTRUIR TELA
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceAtual,
        children: _telas,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
