import 'package:flutter/material.dart';

import '../models/notificacion.dart';
import '../services/notificacion_service.dart';
import '../services/push_service.dart';
import '../widgets/pantalla_naranja.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  static const routeName = '/notificaciones';

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  static const Color _textoOscuro = Color(0xFF4A4A4A);

  final NotificacionService _service = NotificacionService();

  late Future<List<Notificacion>> _futuro;

  /// Posiciones de la lista cuya descripción se está mostrando completa.
  final Set<int> _expandidas = <int>{};

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<List<Notificacion>> _cargar() async {
    final token = await PushService.instance.obtenerToken();
    if (token == null) throw const SinTokenException();
    return _service.getNotificaciones(token);
  }

  Future<void> _recargar() async {
    final futuro = _cargar();
    setState(() {
      _futuro = futuro;
      _expandidas.clear();
    });
    // El RefreshIndicator se mantiene girando hasta que termina la petición.
    await futuro.catchError((_) => <Notificacion>[]);
  }

  @override
  Widget build(BuildContext context) {
    return PantallaNaranja(titulo: 'Notificaciones', child: _buildContenido());
  }

  Widget _buildContenido() {
    return FutureBuilder<List<Notificacion>>(
      future: _futuro,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          return EstadoPantalla(
            icono: Icons.wifi_off,
            texto: snapshot.error is SinTokenException
                ? 'No se pudo identificar el dispositivo.\nRevisa los permisos de notificaciones.'
                : 'No se pudieron cargar las notificaciones.',
            onReintentar: _recargar,
          );
        }

        final notificaciones = snapshot.data ?? const <Notificacion>[];
        if (notificaciones.isEmpty) {
          return const EstadoPantalla(
            icono: Icons.notifications_off,
            texto: 'No tienes notificaciones por ahora.',
          );
        }

        return RefreshIndicator(
          color: kAcenteNaranja,
          onRefresh: _recargar,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: notificaciones.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) =>
                _buildTarjeta(notificaciones[index], index),
          ),
        );
      },
    );
  }

  Widget _buildTarjeta(Notificacion notificacion, int index) {
    final expandida = _expandidas.contains(index);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: Colors.black45,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() {
          if (expandida) {
            _expandidas.remove(index);
          } else {
            _expandidas.add(index);
          }
        }),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    formatoFechaCorta(notificacion.fechaCreacion),
                    style: const TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                  const Spacer(),
                  // Punto naranja para distinguir las que aún no se han leído.
                  if (notificacion.sinLeer)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: kAcenteNaranja,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                notificacion.asunto,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notificacion.descripcion,
                      // Colapsada muestra solo una línea; al tocar se ve completa.
                      maxLines: expandida ? null : 1,
                      overflow: expandida
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textoOscuro,
                        fontSize: 16,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expandida ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black38,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// El dispositivo aún no tiene token de Firebase, así que no hay qué consultar.
class SinTokenException implements Exception {
  const SinTokenException();
}
