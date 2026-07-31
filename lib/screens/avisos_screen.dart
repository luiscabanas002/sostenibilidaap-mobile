import 'package:flutter/material.dart';

import '../models/aviso.dart';
import '../services/avisos_service.dart';
import '../widgets/pantalla_naranja.dart';

class AvisosScreen extends StatefulWidget {
  const AvisosScreen({super.key});

  static const routeName = '/avisos';

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  final AvisosService _service = AvisosService();

  late Future<List<Aviso>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _service.getAvisos();
  }

  Future<void> _recargar() async {
    final futuro = _service.getAvisos();
    // Cuerpo de bloque: con `=>` el callback devolvería el Future y setState lo
    // rechaza al confundirlo con trabajo asíncrono.
    setState(() {
      _futuro = futuro;
    });
    // El RefreshIndicator se mantiene girando hasta que termina la petición.
    await futuro.catchError((_) => <Aviso>[]);
  }

  void _abrirAviso(Aviso aviso) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VisorAvisoScreen(aviso: aviso)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PantallaNaranja(titulo: 'Avisos', child: _buildContenido());
  }

  Widget _buildContenido() {
    return FutureBuilder<List<Aviso>>(
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
            texto: 'No se pudieron cargar los avisos.',
            onReintentar: _recargar,
          );
        }

        final avisos = snapshot.data ?? const <Aviso>[];
        if (avisos.isEmpty) {
          return const EstadoPantalla(
            icono: Icons.campaign_outlined,
            texto: 'No hay avisos publicados.',
          );
        }

        return RefreshIndicator(
          color: kAcenteNaranja,
          onRefresh: _recargar,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: avisos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) => _buildTarjeta(avisos[index]),
          ),
        );
      },
    );
  }

  Widget _buildTarjeta(Aviso aviso) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: Colors.black45,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _abrirAviso(aviso),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Hero(
                  tag: 'aviso-${aviso.idAviso}',
                  child: _MiniaturaAviso(url: aviso.url),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatoFechaCorta(aviso.fecha),
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      aviso.titulo,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.black26,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Miniatura del cartel del aviso, con su propio estado de carga y error.
class _MiniaturaAviso extends StatelessWidget {
  const _MiniaturaAviso({required this.url});

  static const double _ancho = 92;
  static const double _alto = 116;

  final String url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _ancho,
      height: _alto,
      child: url.isEmpty
          ? _buildPlaceholder()
          : Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kAcenteNaranja,
                    ),
                  ),
                );
              },
              errorBuilder: (_, _, _) => _buildPlaceholder(),
            ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Colors.black26),
    );
  }
}

/// Muestra el cartel completo, con zoom para poder leer el contenido.
class VisorAvisoScreen extends StatelessWidget {
  const VisorAvisoScreen({super.key, required this.aviso});

  final Aviso aviso;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                Expanded(
                  child: Text(
                    aviso.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            Expanded(
              child: Hero(
                tag: 'aviso-${aviso.idAviso}',
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Image.network(
                    aviso.url,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: kAcenteNaranja,
                        ),
                      );
                    },
                    errorBuilder: (_, _, _) => const Center(
                      child: Text(
                        'No se pudo cargar la imagen del aviso.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                formatoFechaCorta(aviso.fecha),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
