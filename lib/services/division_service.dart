import '../core/network/api_client.dart';
import '../models/division.dart';

class DivisionService {
  Future<List<Division>> getDivisions() async {
    final crudas = await getDivisionesJson();
    return crudas.map(Division.fromJson).toList();
  }

  /// Respuesta cruda; el modo offline la guarda tal cual en el dispositivo.
  Future<List<Map<String, dynamic>>> getDivisionesJson() async {
    final response = await ApiClient.dio.get<List<dynamic>>('/Division');

    return (response.data ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
