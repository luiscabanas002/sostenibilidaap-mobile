import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/usuario.dart';

/// La clave de empleado no existe para el tipo de registro y división dados.
class ClaveNoEncontradaException implements Exception {}

class UsuarioService {
  /// Clave usada para ingresar como invitado.
  static const String claveInvitado = '00000';

  Future<Usuario> login({
    required int idTipoFactor,
    required int idDivision,
    required String clave,
  }) async {
    try {
      final response = await ApiClient.dio.get<Map<String, dynamic>>(
        '/Usuario/$idTipoFactor/$idDivision/${Uri.encodeComponent(clave)}',
      );
      return Usuario.fromJson(response.data!);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      // El contrato indica 401; el backend actual responde 404 para claves
      // inexistentes, por lo que ambos se tratan como clave no encontrada.
      if (statusCode == 401 || statusCode == 404) {
        throw ClaveNoEncontradaException();
      }
      rethrow;
    }
  }
}
