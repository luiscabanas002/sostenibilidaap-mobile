class Usuario {
  const Usuario({
    required this.nombre,
    required this.idSucursal,
    required this.idUsuario,
    required this.nombreSucursal,
    this.info,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'] as String,
      idSucursal: json['id_sucursal'] as int,
      idUsuario: json['id_usuario'] as int,
      nombreSucursal: json['nombre_sucursal'] as String,
      info: json['info'] == null
          ? null
          : UsuarioInfo.fromJson(json['info'] as Map<String, dynamic>),
    );
  }

  final String nombre;
  final int idSucursal;
  final int idUsuario;
  final String nombreSucursal;
  final UsuarioInfo? info;

  /// Tipo de factor del registro en curso; si el backend no lo devuelve
  /// con ese id, se usa el primero disponible.
  TipoFactor? tipoFactorDe(int idTipoFactor) {
    final tipos = info?.tiposFactores ?? [];
    for (final tipo in tipos) {
      if (tipo.idTipoFactor == idTipoFactor) return tipo;
    }
    return tipos.isEmpty ? null : tipos.first;
  }
}

class UsuarioInfo {
  const UsuarioInfo({
    required this.areas,
    required this.sucursales,
    required this.tiposFactores,
  });

  factory UsuarioInfo.fromJson(Map<String, dynamic> json) {
    return UsuarioInfo(
      areas: (json['areas'] as List<dynamic>? ?? [])
          .map((item) => Area.fromJson(item as Map<String, dynamic>))
          .toList(),
      sucursales: (json['sucursales'] as List<dynamic>? ?? [])
          .map((item) => Sucursal.fromJson(item as Map<String, dynamic>))
          .toList(),
      tiposFactores: (json['tiposFactores'] as List<dynamic>? ?? [])
          .map((item) => TipoFactor.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<Area> areas;
  final List<Sucursal> sucursales;
  final List<TipoFactor> tiposFactores;
}

class Area {
  const Area({
    required this.idArea,
    required this.idEstatus,
    required this.nombre,
    required this.numPosicion,
    required this.pathIcono,
    required this.tipo,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      idArea: json['idArea'] as int,
      idEstatus: json['idEstatus'] as int,
      nombre: json['nombre'] as String,
      numPosicion: json['numPosicion'] as int,
      pathIcono: json['pathIcono'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
    );
  }

  final int idArea;
  final int idEstatus;
  final String nombre;
  final int numPosicion;
  final String pathIcono;
  final String tipo;
}

class Sucursal {
  const Sucursal({
    required this.idSucursal,
    required this.nombre,
    required this.idDivision,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      idSucursal: json['idSucursal'] as int,
      nombre: json['nombre'] as String,
      idDivision: json['idDivision'] as int,
    );
  }

  final int idSucursal;
  final String nombre;
  final int idDivision;
}

class TipoFactor {
  const TipoFactor({
    required this.idTipoFactor,
    required this.idEstatus,
    required this.nombre,
    required this.desMensaje1,
    required this.desMensaje2,
    required this.factores,
  });

  factory TipoFactor.fromJson(Map<String, dynamic> json) {
    return TipoFactor(
      idTipoFactor: json['idTipoFactor'] as int,
      idEstatus: json['idEstatus'] as int,
      nombre: json['nombre'] as String,
      desMensaje1: json['desMensaje1'] as String? ?? '',
      desMensaje2: json['desMensaje2'] as String? ?? '',
      factores: (json['factores'] as List<dynamic>? ?? [])
          .map((item) => Factor.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int idTipoFactor;
  final int idEstatus;
  final String nombre;
  final String desMensaje1;
  final String desMensaje2;
  final List<Factor> factores;
}

class Factor {
  const Factor({
    required this.idFactor,
    required this.idTipoFactor,
    required this.idEstatus,
    required this.nombre,
    required this.numPosicion,
    required this.pathIcono,
  });

  factory Factor.fromJson(Map<String, dynamic> json) {
    return Factor(
      idFactor: json['idFactor'] as int,
      idTipoFactor: json['idTipoFactor'] as int,
      idEstatus: json['idEstatus'] as int,
      nombre: json['nombre'] as String,
      numPosicion: json['numPosicion'] as int,
      pathIcono: json['pathIcono'] as String? ?? '',
    );
  }

  final int idFactor;
  final int idTipoFactor;
  final int idEstatus;
  final String nombre;
  final int numPosicion;
  final String pathIcono;
}
