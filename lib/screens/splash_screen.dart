import 'dart:async';

import 'package:flutter/material.dart';

import '../core/flavor_config.dart';
import '../utils/responsive.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _goToLogin);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final background = context.isTablet
        ? 'assets/images/ic_splash_tablet.png'
        : 'assets/images/ic_splash_mobile.png';

    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          background,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback si aún no se han agregado las imágenes al proyecto.
            return ColoredBox(
              color: const Color(0xFFF57C00),
              child: Center(
                child: Text(
                  FlavorConfig.current.splashFallbackText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
