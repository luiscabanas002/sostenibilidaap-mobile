import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/usuario.dart';

/// La clave de empleado no existe para el tipo de registro y división dados.
/// [mensaje] trae la explicación del backend cuando la manda.
class ClaveNoEncontradaException implements Exception {
  ClaveNoEncontradaException([this.mensaje]);

  final String? mensaje;
}

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

  /// Valida la clave para la sincronización. A diferencia del login no pide
  /// tipo de registro, porque cada levantamiento guardado ya trae el suyo.
  Future<Usuario> validarUsuario({
    required int idDivision,
    required String clave,
  }) async {
    try {
      final response = await ApiClient.dio.get<Map<String, dynamic>>(
        '/Usuario/ValidarUsuario/$idDivision/${Uri.encodeComponent(clave)}',
      );

      final data = response.data ?? const <String, dynamic>{};
      final usuario = data['usuario'];
      if (data['valido'] != true || usuario is! Map<String, dynamic>) {
        throw ClaveNoEncontradaException();
      }
      return Usuario.fromJson(usuario);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw ClaveNoEncontradaException(_mensajeDeError(error));
      }
      rethrow;
    }
  }

  /// El servicio de validación responde el 404 con texto plano.
  String? _mensajeDeError(DioException error) {
    final data = error.response?.data;
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is Map<String, dynamic>) {
      final mensaje = data['mensaje'] ?? data['message'];
      if (mensaje is String && mensaje.trim().isNotEmpty) return mensaje;
    }
    return null;
  }

  /// Catálogo completo (áreas, sucursales y factores) para el modo offline.
  /// Se devuelve crudo porque se guarda tal cual en el dispositivo.
  Future<Map<String, dynamic>> getCatalogoOffline() async {
    final response = await ApiClient.dio.get<Map<String, dynamic>>(
      '/Usuario/Offline',
    );
    return response.data!;
  }
}
