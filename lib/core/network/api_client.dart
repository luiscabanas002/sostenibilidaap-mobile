import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Cliente HTTP central de la app. Todos los servicios deben usar
/// [ApiClient.dio] para heredar la URL base, timeouts y logging.
class ApiClient {
  ApiClient._();

  static final Dio dio = _build();

  /// Host base del backend, sin sufijo `/api`. Es la fuente única de verdad
  /// para armar tanto [baseUrl] como la URL base de recursos estáticos
  /// (ver [kMediaBaseUrl] en `core/media.dart`).
  ///
  /// El emulador de Android expone el localhost de la máquina en 10.0.2.2.
  static String get serverBaseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5093';
    }
    return 'http://localhost:5093';
  }

  static String get baseUrl => '$serverBaseUrl/api';

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (message) => debugPrint('[API] $message'),
        ),
      );
    }

    return dio;
  }
}
