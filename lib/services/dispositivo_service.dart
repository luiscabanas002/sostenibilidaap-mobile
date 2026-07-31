import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';

class DispositivoService {
  /// Registra el token de Firebase del dispositivo para notificaciones.
  /// Devuelve el mensaje que responde el servicio.
  Future<String?> registrar({
    required String token,
    int? idUsuario,
  }) async {
    final response = await ApiClient.dio.post<Map<String, dynamic>>(
      '/Dispositivo/registrar',
      data: {'token': token, 'so': _sistemaOperativo, 'id_usuario': idUsuario},
    );

    return response.data?['mensaje'] as String?;
  }

  String get _sistemaOperativo {
    if (!kIsWeb && Platform.isIOS) return 'IOS';
    return 'ANDROID';
  }
}
