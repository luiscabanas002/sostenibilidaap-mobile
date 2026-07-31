import 'package:flutter/material.dart';

import '../utils/responsive.dart';
import 'barra_navegacion_registro.dart';

/// Naranja del tema de login/avisos/notificaciones.
const Color kAcenteNaranja = Color(0xFFEF8140);

/// Estructura común de las pantallas secundarias del login: fondo naranja,
/// flecha para regresar, título centrado y logo de Bepensa al final.
class PantallaNaranja extends StatelessWidget {
  const PantallaNaranja({
    super.key,
    required this.titulo,
    required this.child,
    this.anchoMaximo = 700,
  });

  final String titulo;
  final Widget child;
  final double anchoMaximo;

  @override
  Widget build(BuildContext context) {
    final fondo = context.isTablet
        ? 'assets/images/fondo_naranja1_tablet.png'
        : 'assets/images/fondo_naranja1_mobile.png';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(fondo), fit: BoxFit.cover),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: anchoMaximo),
              child: Column(
                children: [
                  _buildEncabezado(context),
                  Expanded(child: child),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: Image.asset(
                      'assets/images/logo_bepensa.png',
                      height: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: TituloRegistro(titulo),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Image.asset(
                'assets/images/iconos/ic_left.png',
                width: 26,
                height: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Mensaje centrado para los estados vacío y de error.
class EstadoPantalla extends StatelessWidget {
  const EstadoPantalla({
    super.key,
    required this.icono,
    required this.texto,
    this.onReintentar,
  });

  final IconData icono;
  final String texto;
  final VoidCallback? onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onReintentar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kAcenteNaranja,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'REINTENTAR',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Fecha corta dd/MM/yyyy, sin depender de intl.
String formatoFechaCorta(DateTime? fecha) {
  if (fecha == null) return '';
  final local = fecha.toLocal();
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  return '$dia/$mes/${local.year}';
}
