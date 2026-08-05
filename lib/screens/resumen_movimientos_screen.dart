import 'package:flutter/material.dart';

import '../core/registro_tema.dart';
import '../models/registro_borrador.dart';
import '../utils/responsive.dart';
import 'splash_screen.dart';

class ResumenMovimientosScreen extends StatelessWidget {
  const ResumenMovimientosScreen({
    super.key,
    required this.borrador,
    this.titulo = '¡Ya terminaste!',
    this.mensaje =
        'Gracias por hacer de Bepensa un lugar más seguro para trabajar.',
  });

  static const routeName = '/resumen-movimientos';

  final RegistroBorrador borrador;

  /// Lo manda comentarios con el mensaje que devuelve el backend.
  final String titulo;
  final String mensaje;

  RegistroTema get _tema => RegistroTema.de(borrador.idTipoFactor);

  void _salir(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(SplashScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              _tema.fondoSalidaAsset(esTablet: context.isTablet),
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildTarjeta(context),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTarjeta(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/iconos/ic_salir.png',
            width: 84,
            height: 84,
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87, fontSize: 20),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _salir(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _tema.acentoBoton,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'SALIR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
