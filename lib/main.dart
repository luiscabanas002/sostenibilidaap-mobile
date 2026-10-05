import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/flavor_config.dart';
import 'flavors.dart';
import 'screens/avisos_screen.dart';
import 'screens/login_screen.dart';
import 'screens/modo_offline_screen.dart';
import 'screens/notificaciones_screen.dart';
import 'screens/registro_usuario_screen.dart';
import 'screens/splash_screen.dart';
import 'services/offline_store.dart';
import 'services/push_service.dart';
import 'utils/responsive.dart';
import 'widgets/pantalla_naranja.dart';

Future<void> main() => mainCommon(Flavor.bepensa);

Future<void> mainCommon(Flavor flavor) async {
  F.appFlavor = flavor;
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
    isTabletDevice()
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : [DeviceOrientation.portraitUp],
  );

  // El catálogo offline se lee antes de abrir para que el login sepa de una
  // vez si debe trabajar contra el servidor o contra los datos locales.
  await OfflineStore.instance.cargar();

  // No bloquea el arranque: si Firebase o el backend fallan, la app abre igual.
  unawaited(PushService.instance.inicializar());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlavorConfig.current.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kAcenteNaranja),
        ),
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        NotificacionesScreen.routeName: (_) => const NotificacionesScreen(),
        AvisosScreen.routeName: (_) => const AvisosScreen(),
        RegistroUsuarioScreen.routeName: (_) => const RegistroUsuarioScreen(),
        ModoOfflineScreen.routeName: (_) => const ModoOfflineScreen(),
      },
    );
  }
}
