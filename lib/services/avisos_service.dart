import '../core/network/api_client.dart';
import '../models/aviso.dart';

class AvisosService {
  Future<List<Aviso>> getAvisos() async {
    final response = await ApiClient.dio.get<List<dynamic>>('/Avisos/getAvisos');

    return (response.data ?? [])
        .map((item) => Aviso.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
