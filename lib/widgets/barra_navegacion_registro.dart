import 'package:flutter/material.dart';

/// Barra inferior del cuestionario: regresar a la izquierda, logo Bepensa
/// al centro y continuar a la derecha.
class BarraNavegacionRegistro extends StatelessWidget {
  const BarraNavegacionRegistro({
    super.key,
    required this.onAtras,
    required this.onContinuar,
  });

  static const _iconosPath = 'assets/images/iconos';

  final VoidCallback onAtras;
  final VoidCallback onContinuar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBoton(icono: '$_iconosPath/ic_left.png', onTap: onAtras),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Image.asset('assets/images/logo_bepensa.png', height: 30),
          ),
          _buildBoton(icono: '$_iconosPath/ic_right.png', onTap: onContinuar),
        ],
      ),
    );
  }

  Widget _buildBoton({required String icono, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
        child: Image.asset(icono, width: 32, height: 40),
      ),
    );
  }
}

/// Título blanco centrado que encabeza las pantallas del cuestionario.
class TituloRegistro extends StatelessWidget {
  const TituloRegistro(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
