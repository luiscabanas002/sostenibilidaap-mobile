import 'usuario.dart';

/// Datos capturados en el formulario de registro, listos para la
/// pantalla de comentarios y el envío final.
class RegistroBorrador {
  const RegistroBorrador({
    required this.usuario,
    required this.idTipoFactor,
    required this.fecha,
    required this.sucursal,
    required this.tipoComportamiento,
    required this.area,
    required this.factor,
    this.probabilidadEventoSerio,
    this.maquinariaEquipo,
    this.observaciones,
    this.acciones,
  });

  /// Devuelve una copia con los comentarios capturados en su pantalla.
  RegistroBorrador conComentarios({String? observaciones, String? acciones}) {
    return RegistroBorrador(
      usuario: usuario,
      idTipoFactor: idTipoFactor,
      fecha: fecha,
      sucursal: sucursal,
      tipoComportamiento: tipoComportamiento,
      probabilidadEventoSerio: probabilidadEventoSerio,
      maquinariaEquipo: maquinariaEquipo,
      area: area,
      factor: factor,
      observaciones: observaciones,
      acciones: acciones,
    );
  }

  final Usuario usuario;
  final int idTipoFactor;
  final DateTime fecha;
  final Sucursal sucursal;
  final String tipoComportamiento;
  final Area area;
  final Factor factor;

  /// 'Sí' / 'No'. Null cuando el tipo de registro no lo captura.
  final String? probabilidadEventoSerio;

  /// Solo aplica en Condiciones Ambientales.
  final String? maquinariaEquipo;

  /// Comentarios opcionales capturados en la pantalla de comentarios.
  final String? observaciones;
  final String? acciones;
}
