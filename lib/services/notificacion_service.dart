import '../core/network/api_client.dart';
import '../models/notificacion.dart';

class NotificacionService {
  /// Las notificaciones se consultan por el token del dispositivo, no por
  /// usuario: es el mismo token que se registró en /Dispositivo/registrar.
  Future<List<Notificacion>> getNotificaciones(String token) async {
    final response = await ApiClient.dio.get<List<dynamic>>(
      '/Notificacion/getnotificaciones',
      queryParameters: {'token': token},
    );

    return (response.data ?? [])
        .map((item) => Notificacion.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
