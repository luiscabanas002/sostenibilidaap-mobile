import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';

/// Guarda en el dispositivo el catálogo del modo offline y los levantamientos
/// que todavía no se han sincronizado.
///
/// Se carga una sola vez al arrancar ([cargar]) y a partir de ahí todo se lee
/// de memoria, para que las pantallas puedan consultarlo sin `await`.
class OfflineStore {
  OfflineStore._();

  static final OfflineStore instance = OfflineStore._();

  static const _kActivo = 'offline_activo';
  static const _kCatalogo = 'offline_catalogo';
  static const _kFecha = 'offline_fecha_descarga';
  static const _kPendientes = 'offline_pendientes';

  late final SharedPreferences _prefs;

  bool _activo = false;
  Usuario? _catalogo;
  DateTime? _fechaDescarga;
  List<Map<String, dynamic>> _pendientes = [];

  bool get activo => _activo;
  Usuario? get catalogo => _catalogo;
  DateTime? get fechaDescarga => _fechaDescarga;
  List<Map<String, dynamic>> get pendientes => List.unmodifiable(_pendientes);

  bool get hayCatalogo => _catalogo != null;

  Future<void> cargar() async {
    _prefs = await SharedPreferences.getInstance();

    _activo = _prefs.getBool(_kActivo) ?? false;

    final catalogo = _prefs.getString(_kCatalogo);
    if (catalogo != null) {
      _catalogo = Usuario.fromJson(
        jsonDecode(catalogo) as Map<String, dynamic>,
      );
    }

    final fecha = _prefs.getString(_kFecha);
    if (fecha != null) _fechaDescarga = DateTime.tryParse(fecha);

    final pendientes = _prefs.getString(_kPendientes);
    if (pendientes != null) {
      _pendientes = (jsonDecode(pendientes) as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }
  }

  /// Sin catálogo descargado el modo offline no se puede encender.
  Future<void> setActivo(bool valor) async {
    _activo = valor && hayCatalogo;
    await _prefs.setBool(_kActivo, _activo);
  }

  Future<void> guardarCatalogo(Map<String, dynamic> usuario) async {
    _catalogo = Usuario.fromJson(usuario);
    _fechaDescarga = DateTime.now();

    await _prefs.setString(_kCatalogo, jsonEncode(usuario));
    await _prefs.setString(_kFecha, _fechaDescarga!.toIso8601String());
  }

  Future<void> borrarCatalogo() async {
    _catalogo = null;
    _fechaDescarga = null;
    _activo = false;

    await _prefs.remove(_kCatalogo);
    await _prefs.remove(_kFecha);
    await _prefs.setBool(_kActivo, false);
  }

  /// Encola un levantamiento ya armado con el cuerpo que espera el backend.
  Future<void> agregarPendiente(Map<String, dynamic> cuerpo) async {
    _pendientes = [..._pendientes, cuerpo];
    await _guardarPendientes();
  }

  Future<void> limpiarPendientes() async {
    _pendientes = [];
    await _guardarPendientes();
  }

  Future<void> _guardarPendientes() {
    return _prefs.setString(_kPendientes, jsonEncode(_pendientes));
  }
}
