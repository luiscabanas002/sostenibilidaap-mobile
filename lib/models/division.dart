class Division {
  const Division({
    required this.idDivision,
    required this.descripcion,
    required this.aplicaCodigo,
    required this.aplicaSucursal,
    this.info,
  });

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      idDivision: json['idDivision'] as int,
      descripcion: json['descripcion'] as String,
      aplicaCodigo: json['aplicaCodigo'] as int,
      aplicaSucursal: json['aplicaSucursal'] as int,
      info: json['info'] as String?,
    );
  }

  final int idDivision;
  final String descripcion;
  final int aplicaCodigo;
  final int aplicaSucursal;
  final String? info;
}
