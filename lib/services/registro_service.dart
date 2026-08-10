import '../core/network/api_client.dart';
import '../models/catalogos_registro.dart';
import '../models/proceso.dart';

/// El alta no se guardó aunque la petición haya respondido 200.
/// [mensaje] trae la explicación del backend cuando la manda.
class RegistroRechazadoException implements Exception {
  RegistroRechazadoException([this.mensaje]);

  final String? mensaje;
}

class RegistroService {
  /// Países, puestos y divisiones para los selectores del formulario.
  Future<CatalogosRegistro> getCatalogos() async {
    final response = await ApiClient.dio.get<Map<String, dynamic>>(
      '/Register/GetCatalogs',
    );

    return CatalogosRegistro.fromJson(response.data ?? const {});
  }

  /// Árbol proceso → subproceso → sucursal de una división.
  Future<List<Proceso>> getProcesos(int idDivision) async {
    final response = await ApiClient.dio.get<List<dynamic>>(
      '/Register/GetDivisionInformation/$idDivision',
    );

    return (response.data ?? [])
        .map((item) => Proceso.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Da de alta al usuario. Devuelve el mensaje del backend si lo trae.
  Future<String?> registrarUsuario({
    required String clave,
    required String nombre,
    required String pais,
    required int idDivision,
    required int idProceso,
    required int idSubProceso,
    required int idPuesto,
    required int idSucursal,
  }) async {
    final response = await ApiClient.dio.post<dynamic>(
      '/Register/RegistrarUsuario',
      data: {
        'clave': clave,
        'nombre': nombre,
        'pais': pais,
        'id_division': idDivision,
        'id_proceso': idProceso,
        'id_sub_proceso': idSubProceso,
        'id_puesto': idPuesto,
        'id_sucursal': idSucursal,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) return null;

    final mensaje = data['mensaje'] as String?;
    // El backend puede rechazar el alta respondiendo 200 con success en false.
    if (data['success'] == false) {
      throw RegistroRechazadoException(mensaje);
    }
    return mensaje;
  }
}
