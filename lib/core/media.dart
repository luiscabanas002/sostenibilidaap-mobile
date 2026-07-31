/// Base pública donde se hospedan las imágenes del backend.
const String kMediaBaseUrl = 'http://app.bepensa-web.com/';

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
