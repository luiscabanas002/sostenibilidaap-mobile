class Notificacion {
  const Notificacion({
    required this.idNotificacion,
    required this.asunto,
    required this.descripcion,
    required this.leido,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.idUsuario,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      idNotificacion: json['id_notificacion'] as int? ?? 0,
      asunto: json['asunto'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      leido: json['leido'] as int? ?? 0,
      fechaCreacion: _fecha(json['fecha_creacion']),
      fechaActualizacion: _fecha(json['fecha_actualizacion']),
      idUsuario: json['id_usuario'] as int?,
    );
  }

  static DateTime? _fecha(dynamic valor) {
    if (valor is! String) return null;
    return DateTime.tryParse(valor);
  }

  final int idNotificacion;
  final String asunto;
  final String descripcion;
  final int leido;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final int? idUsuario;

  bool get sinLeer => leido == 0;
}
