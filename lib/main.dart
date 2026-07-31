import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/avisos_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notificaciones_screen.dart';
import 'screens/splash_screen.dart';
import 'services/push_service.dart';
import 'utils/responsive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
    isTabletDevice()
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : [DeviceOrientation.portraitUp],
  );

  // No bloquea el arranque: si Firebase o el backend fallan, la app abre igual.
  unawaited(PushService.instance.inicializar());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SostenibilidApp',
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        NotificacionesScreen.routeName: (_) => const NotificacionesScreen(),
        AvisosScreen.routeName: (_) => const AvisosScreen(),
      },
    );
  }
}
