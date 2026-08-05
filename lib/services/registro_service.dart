import '../core/network/api_client.dart';
import '../models/catalogos_registro.dart';
import '../models/proceso.dart';

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
    return data is Map<String, dynamic> ? data['mensaje'] as String? : null;
  }
}
