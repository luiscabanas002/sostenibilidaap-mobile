import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import 'dispositivo_service.dart';

/// Inicializa Firebase, pide permiso de notificaciones y registra el token
/// del dispositivo en el backend.
class PushService {
  PushService._();

  static final PushService instance = PushService._();

  final DispositivoService _dispositivoService = DispositivoService();

  /// Último token registrado, para no repetir la llamada al backend.
  String? _tokenRegistrado;

  String? get token => _tokenRegistrado;

  Future<void> inicializar() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    // En iOS el token FCM solo existe una vez que APNs entregó el suyo.
    try {
      final token = await messaging.getToken();
      if (token != null) await _registrar(token);
    } catch (error) {
      debugPrint('[PUSH] No se pudo obtener el token: $error');
    }

    // Firebase rota el token; hay que volver a registrarlo cuando cambie.
    messaging.onTokenRefresh.listen(_registrar);
  }

  /// Token del dispositivo; si el registro inicial falló se vuelve a pedir.
  Future<String?> obtenerToken() async {
    final registrado = _tokenRegistrado;
    if (registrado != null) return registrado;

    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (error) {
      debugPrint('[PUSH] No se pudo obtener el token: $error');
      return null;
    }
  }

  /// Reenvía el token asociándolo a un usuario ya autenticado.
  Future<void> registrarUsuario(int idUsuario) async {
    final token = _tokenRegistrado;
    if (token == null) return;
    await _enviar(token: token, idUsuario: idUsuario);
  }

  Future<void> _registrar(String token) async {
    if (token == _tokenRegistrado) return;
    await _enviar(token: token);
  }

  Future<void> _enviar({required String token, int? idUsuario}) async {
    try {
      final mensaje = await _dispositivoService.registrar(
        token: token,
        idUsuario: idUsuario,
      );
      _tokenRegistrado = token;
      debugPrint('[PUSH] Dispositivo registrado: $mensaje');
    } catch (error) {
      // Sin conexión o backend caído: la app debe seguir funcionando.
      debugPrint('[PUSH] No se pudo registrar el dispositivo: $error');
    }
  }
}
