import 'package:flutter/material.dart';

import '../services/levantamiento_service.dart';
import '../services/offline_store.dart';
import '../services/usuario_service.dart';
import '../widgets/campos_formulario.dart';
import '../widgets/dialogos_registro.dart';
import '../widgets/pantalla_naranja.dart';
import '../widgets/validar_usuario_dialog.dart';

class ModoOfflineScreen extends StatefulWidget {
  const ModoOfflineScreen({super.key});

  static const routeName = '/modo-offline';

  @override
  State<ModoOfflineScreen> createState() => _ModoOfflineScreenState();
}

class _ModoOfflineScreenState extends State<ModoOfflineScreen> {
  static const Color _textoOscuro = Color(0xFF4A4A4A);
  static const Color _verde = Color(0xFFA3BF38);

  final UsuarioService _usuarioService = UsuarioService();
  final LevantamientoService _levantamientoService = LevantamientoService();

  OfflineStore get _store => OfflineStore.instance;

  bool _descargando = false;
  bool _sincronizando = false;

  Future<void> _descargarCatalogo() async {
    if (_descargando) return;
    setState(() {
      _descargando = true;
    });

    try {
      final catalogo = await _usuarioService.getCatalogoOffline();
      await _store.guardarCatalogo(catalogo);

      if (!mounted) return;
      setState(() {
        _descargando = false;
      });
      _avisar('Información descargada en el dispositivo.');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _descargando = false;
      });
      _avisar('No se pudo descargar la información. Revisa tu conexión.');
    }
  }

  Future<void> _cambiarModo(bool valor) async {
    if (valor && !_store.hayCatalogo) {
      _avisar('Primero descarga la información.');
      return;
    }

    await _store.setActivo(valor);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _sincronizar() async {
    if (_sincronizando || _store.pendientes.isEmpty) return;

    if (_store.activo) {
      final continuar = await showConfirmacionDialog(
        context,
        titulo: 'Modo offline activo',
        mensaje: 'Para sincronizar se necesita conexión. ¿Deseas continuar?',
        textoNegativo: 'CANCELAR',
        textoPositivo: 'CONTINUAR',
      );
      if (!continuar || !mounted) return;
    }

    final validado = await showValidarUsuarioDialog(context);
    if (validado == null || !mounted) return;

    setState(() {
      _sincronizando = true;
    });

    try {
      // El usuario y la división no se conocían al guardar sin conexión:
      // se completan aquí con los datos recién validados.
      final cuerpos = _store.pendientes
          .map(
            (cuerpo) => {
              ...cuerpo,
              'id_usuario': validado.usuario.idUsuario,
              'id_division': validado.division.idDivision,
            },
          )
          .toList();

      final mensaje = await _levantamientoService.registrarLista(cuerpos);
      await _store.limpiarPendientes();

      if (!mounted) return;
      setState(() {
        _sincronizando = false;
      });
      _avisar(mensaje ?? 'Levantamientos sincronizados.');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sincronizando = false;
      });
      _avisar('No se pudieron sincronizar. Los datos siguen guardados.');
    }
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return PantallaNaranja(
      titulo: 'Modo offline',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          _buildTarjetaCatalogo(),
          const SizedBox(height: 16),
          _buildTarjetaInterruptor(),
          const SizedBox(height: 16),
          _buildTarjetaPendientes(),
        ],
      ),
    );
  }

  Widget _buildTarjetaCatalogo() {
    final descargado = _store.hayCatalogo;
    final fecha = _store.fechaDescarga;

    return TarjetaBlanca(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                descargado ? Icons.cloud_done : Icons.cloud_off,
                color: descargado ? _verde : Colors.black26,
                size: 34,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      descargado
                          ? 'Información descargada'
                          : 'Sin información descargada',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descargado
                          ? 'Última descarga: ${_fechaHora(fecha)}'
                          : 'Descárgala para poder trabajar sin conexión.',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (descargado) ...[
            const SizedBox(height: 12),
            _buildResumenCatalogo(),
          ],
          const SizedBox(height: 16),
          BotonAccion(
            texto: descargado ? 'ACTUALIZAR INFORMACIÓN' : 'DESCARGAR',
            cargando: _descargando,
            onPressed: _descargarCatalogo,
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCatalogo() {
    final info = _store.catalogo?.info;
    final areas = info?.areas.length ?? 0;
    final sucursales = info?.sucursales.length ?? 0;
    final factores =
        info?.tiposFactores.fold<int>(
          0,
          (total, tipo) => total + tipo.factores.length,
        ) ??
        0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black12.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDato('$areas', 'Áreas'),
          _buildDato('$sucursales', 'Plantas'),
          _buildDato('$factores', 'Factores'),
        ],
      ),
    );
  }

  Widget _buildDato(String valor, String etiqueta) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          etiqueta,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTarjetaInterruptor() {
    final habilitado = _store.hayCatalogo;

    return TarjetaBlanca(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _store.activo,
        onChanged: habilitado ? _cambiarModo : null,
        activeThumbColor: Colors.white,
        activeTrackColor: kAcenteNaranja,
        title: const Text(
          'Trabajar sin conexión',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          habilitado
              ? 'Los registros se guardan en el dispositivo hasta que los '
                    'sincronices.'
              : 'Disponible después de descargar la información.',
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTarjetaPendientes() {
    final pendientes = _store.pendientes;

    return TarjetaBlanca(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync, color: Colors.black54, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pendientes.isEmpty
                      ? 'Sin levantamientos pendientes'
                      : '${pendientes.length} ${pendientes.length == 1 ? 'levantamiento pendiente' : 'levantamientos pendientes'}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (pendientes.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final cuerpo in pendientes) _buildFilaPendiente(cuerpo),
            const SizedBox(height: 8),
            BotonAccion(
              texto: 'SINCRONIZAR',
              cargando: _sincronizando,
              onPressed: _sincronizar,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilaPendiente(Map<String, dynamic> cuerpo) {
    final tipo = cuerpo['tipo_levantamiento'] as String? ?? '';
    final fecha = DateTime.tryParse(
      cuerpo['fecha_hora_registro'] as String? ?? '',
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.description, color: Colors.black26, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _nombreTipo(tipo),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _textoOscuro, fontSize: 15),
            ),
          ),
          Text(
            _fechaHora(fecha),
            style: const TextStyle(color: Colors.black38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _nombreTipo(String tipo) {
    switch (tipo) {
      case 'TOC':
        return 'Comportamientos';
      case 'CONDICIONES':
        return 'Condiciones';
      case 'AMBIENTAL':
        return 'Condiciones Ambientales';
      default:
        return tipo;
    }
  }

  String _fechaHora(DateTime? fecha) {
    if (fecha == null) return '';
    final local = fecha.toLocal();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '${formatoFechaCorta(local)} $hora:$minuto';
  }
}
