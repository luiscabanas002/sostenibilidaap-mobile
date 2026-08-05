/// Estructura que devuelve /Register/GetDivisionInformation: cada proceso
/// trae sus subprocesos y cada subproceso sus sucursales.
class Proceso {
  const Proceso({
    required this.idProceso,
    required this.nombre,
    required this.subProcesos,
  });

  factory Proceso.fromJson(Map<String, dynamic> json) {
    return Proceso(
      idProceso: json['idProceso'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      subProcesos: (json['subProcesos'] as List<dynamic>? ?? [])
          .map((item) => SubProceso.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int idProceso;
  final String nombre;
  final List<SubProceso> subProcesos;
}

class SubProceso {
  const SubProceso({
    required this.idSubProceso,
    required this.nombre,
    required this.sucursales,
  });

  factory SubProceso.fromJson(Map<String, dynamic> json) {
    return SubProceso(
      idSubProceso: json['idSubProceso'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      sucursales: (json['sucursales'] as List<dynamic>? ?? [])
          .map((item) => SucursalProceso.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int idSubProceso;
  final String nombre;
  final List<SucursalProceso> sucursales;
}

/// Sucursal tal como llega dentro de un subproceso: solo id y nombre.
class SucursalProceso {
  const SucursalProceso({required this.idSucursal, required this.nombre});

  factory SucursalProceso.fromJson(Map<String, dynamic> json) {
    return SucursalProceso(
      idSucursal: json['idSucursal'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
    );
  }

  final int idSucursal;
  final String nombre;
}
