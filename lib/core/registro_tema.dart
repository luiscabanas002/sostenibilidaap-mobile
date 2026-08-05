import 'package:flutter/material.dart';

/// Configuración visual y de campos de cada tipo de registro. La comparten
/// todas las pantallas del cuestionario para no repetir títulos ni fondos.
class RegistroTema {
  const RegistroTema({
    required this.titulo,
    required this.tipoLevantamiento,
    required this.fondo,
    required this.fondoSalida,
    required this.gridTitulo,
    required this.acento,
    required this.acentoBoton,
    required this.iconoMicro,
    required this.muestraSifp,
    required this.sifpAntesDeTipo,
    required this.muestraMaquinaria,
  });

  final String titulo;

  /// Valor de `tipo_levantamiento` que decide la tabla destino en el backend.
  final String tipoLevantamiento;

  /// Prefijo del asset de fondo (se completa con _mobile/_tablet).
  final String fondo;

  /// Prefijo del fondo de la pantalla final (se completa con _tablet).
  final String fondoSalida;

  /// Título de la cuadrícula de factores.
  final String gridTitulo;

  /// Color fuerte del tipo de registro (micrófonos, cursores).
  final Color acento;

  /// Tono usado en los botones de acción.
  final Color acentoBoton;

  final String iconoMicro;

  final bool muestraSifp;
  final bool sifpAntesDeTipo;
  final bool muestraMaquinaria;

  String fondoAsset({required bool esTablet}) =>
      'assets/images/${fondo}_${esTablet ? 'tablet' : 'mobile'}.png';

  String fondoSalidaAsset({required bool esTablet}) =>
      'assets/images/$fondoSalida${esTablet ? '_tablet' : ''}.png';

  static const Map<int, RegistroTema> _porTipoFactor = {
    1: RegistroTema(
      titulo: 'Registro TOC',
      tipoLevantamiento: 'TOC',
      fondo: 'fondo_naranja2',
      fondoSalida: 'ic_salir_naranja',
      gridTitulo: 'Comportamiento',
      acento: Color(0xFFFD8B17),
      acentoBoton: Color(0xFFEF8140),
      iconoMicro: 'assets/images/iconos/ic_micro_naranja.png',
      muestraSifp: true,
      sifpAntesDeTipo: false,
      muestraMaquinaria: false,
    ),
    2: RegistroTema(
      titulo: 'Registro de Condiciones',
      tipoLevantamiento: 'CONDICIONES',
      fondo: 'fondo_rojo2',
      fondoSalida: 'ic_salir_rojo',
      gridTitulo: 'Condiciones',
      acento: Color(0xFFE71312),
      acentoBoton: Color(0xFFE85C5B),
      iconoMicro: 'assets/images/iconos/ic_micro_rojo.png',
      muestraSifp: true,
      sifpAntesDeTipo: true,
      muestraMaquinaria: false,
    ),
    3: RegistroTema(
      titulo: 'Registro Ambiental',
      tipoLevantamiento: 'AMBIENTAL',
      fondo: 'fondo_verde2',
      fondoSalida: 'ic_salir_verde',
      gridTitulo: 'Comportamiento',
      acento: Color(0xFFA3BF38),
      acentoBoton: Color(0xFFAFC95C),
      iconoMicro: 'assets/images/iconos/ic_micro_verde.png',
      muestraSifp: false,
      sifpAntesDeTipo: false,
      muestraMaquinaria: true,
    ),
  };

  static RegistroTema de(int idTipoFactor) =>
      _porTipoFactor[idTipoFactor] ?? _porTipoFactor[1]!;
}
