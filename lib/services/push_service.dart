import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import 'dispositivo_service.dart';

/// Canal de Android donde caen los avisos. El mismo id se declara en el
/// manifiesto para que las notificaciones que llegan con la app cerrada
/// usen esta importancia y no la de un canal por omisión.
const AndroidNotificationChannel kCanalAvisos = AndroidNotificationChannel(
  'sostenibilidaap_avisos',
  'Avisos',
  description: 'Avisos y recordatorios de Sostenibilidapp.',
  importance: Importance.high,
);

/// En la barra de estado Android pinta de blanco todo lo que no sea
/// transparente, así que este icono vale por su silueta, no por su color.
const String kIconoNotificacion = '@drawable/ic_notificacion';

/// Inicializa Firebase, pide permiso de notificaciones, registra el token
/// del dispositivo en el backend y muestra los avisos que llegan.
class PushService {
  PushService._();

  static final PushService instance = PushService._();

  final DispositivoService _dispositivoService = DispositivoService();
  final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();

  /// Último token registrado, para no repetir la llamada al backend.
  String? _tokenRegistrado;

  String? get token => _tokenRegistrado;

  Future<void> inicializar() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    await _prepararNotificaciones();

    // Con la app abierta el sistema no las muestra solo: hay que pintarlas.
    FirebaseMessaging.onMessage.listen(_mostrarEnPrimerPlano);

    // Toque sobre la notificación con la app en segundo plano o cerrada.
    FirebaseMessaging.onMessageOpenedApp.listen(_alAbrirDesdeNotificacion);
    final inicial = await messaging.getInitialMessage();
    if (inicial != null) _alAbrirDesdeNotificacion(inicial);

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

  Future<void> _prepararNotificaciones() async {
    // En iOS el sistema las presenta solo, incluso con la app en primer plano.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _notificaciones.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(kIconoNotificacion),
        // Los permisos ya los pidió firebase_messaging.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (respuesta) {
        debugPrint('[PUSH] Notificación tocada: ${respuesta.id}');
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      await _notificaciones
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(kCanalAvisos);
    }
  }

  Future<void> _mostrarEnPrimerPlano(RemoteMessage mensaje) async {
    // iOS ya la presenta con setForegroundNotificationPresentationOptions.
    if (kIsWeb || !Platform.isAndroid) return;

    final notificacion = mensaje.notification;
    if (notificacion == null) return;

    await _notificaciones.show(
      id: notificacion.hashCode,
      title: notificacion.title,
      body: notificacion.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          kCanalAvisos.id,
          kCanalAvisos.name,
          channelDescription: kCanalAvisos.description,
          icon: kIconoNotificacion,
          importance: Importance.high,
          priority: Priority.high,
          // El cuerpo puede ser largo; así no se corta a una línea.
          styleInformation: BigTextStyleInformation(notificacion.body ?? ''),
        ),
      ),
    );
  }

  void _alAbrirDesdeNotificacion(RemoteMessage mensaje) {
    // El backend manda solo title/body, así que no hay a dónde navegar:
    // basta con que la app quede abierta.
    debugPrint('[PUSH] App abierta desde: ${mensaje.notification?.title}');
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
