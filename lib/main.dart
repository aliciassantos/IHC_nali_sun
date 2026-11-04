
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/plant_provider.dart';
import 'services/notification_service.dart';

// Chave global de navegação.
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env["SUPABASE_URL"]!,
    publishableKey: dotenv.env["SUPABASE_ANON_KEY"]!,
  );

  // Inicializa as notificações locais.
  await NotificationService.inicializar();

  // Ouve quando o link de recuperação de senha é processado.
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.pushNamed('/reset-password');
    }
  });

  final authProvider = AuthProvider();
  final themeProvider = ThemeProvider();

  await Future.wait([
    authProvider.restoreSession(),
    themeProvider.loadTheme(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
        ),
        ChangeNotifierProvider<PlantProvider>(
          create: (_) => PlantProvider(),
        ),
      ],
      child: const NaliSunApp(),
    ),
  );
}