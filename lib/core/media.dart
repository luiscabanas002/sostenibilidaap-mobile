import 'network/api_client.dart';

/// Base pública donde se hospedan las imágenes del backend.
///
/// Se deriva de [ApiClient.serverBaseUrl] para no duplicar el host/puerto
/// en dos lugares distintos.
String get kMediaBaseUrl => '${ApiClient.serverBaseUrl}/';

/// Convierte un pathIcono del backend (p. ej. `~/Upload/...`) en URL absoluta.
String mediaUrl(String path) {
  var cleaned = path.replaceAll('\\', '/');
  if (cleaned.startsWith('~')) {
    cleaned = cleaned.substring(1);
  }
  if (cleaned.startsWith('/')) {
    cleaned = cleaned.substring(1);
  }
  return '$kMediaBaseUrl$cleaned';
}
