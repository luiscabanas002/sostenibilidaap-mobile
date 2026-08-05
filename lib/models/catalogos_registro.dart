import 'division.dart';

/// Catálogos que alimentan los selectores de la pantalla de registro.
class CatalogosRegistro {
  const CatalogosRegistro({
    required this.paises,
    required this.puestos,
    required this.divisiones,
  });

  factory CatalogosRegistro.fromJson(Map<String, dynamic> json) {
    return CatalogosRegistro(
      paises: (json['paises'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      puestos: (json['puestos'] as List<dynamic>? ?? [])
          .map((item) => Puesto.fromJson(item as Map<String, dynamic>))
          .toList(),
      divisiones: (json['divisiones'] as List<dynamic>? ?? [])
          .map((item) => Division.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<String> paises;
  final List<Puesto> puestos;
  final List<Division> divisiones;
}

class Puesto {
  const Puesto({
    required this.idPuesto,
    required this.clave,
    required this.nombre,
    required this.idEstatus,
  });

  factory Puesto.fromJson(Map<String, dynamic> json) {
    return Puesto(
      idPuesto: json['idPuesto'] as int? ?? 0,
      clave: json['clave'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      idEstatus: json['idEstatus'] as int? ?? 0,
    );
  }

  final int idPuesto;
  final String clave;
  final String nombre;
  final int idEstatus;
}
