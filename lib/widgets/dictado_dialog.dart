import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Abre el diálogo de dictado por voz. Devuelve el texto aceptado por el
/// usuario, o null si canceló.
Future<String?> showDictadoDialog(
  BuildContext context, {
  String textoInicial = '',
  required Color acento,
  required String iconoMicrofono,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _DictadoDialog(
      textoInicial: textoInicial,
      acento: acento,
      iconoMicrofono: iconoMicrofono,
    ),
  );
}

class _DictadoDialog extends StatefulWidget {
  const _DictadoDialog({
    required this.textoInicial,
    required this.acento,
    required this.iconoMicrofono,
  });

  final String textoInicial;
  final Color acento;
  final String iconoMicrofono;

  @override
  State<_DictadoDialog> createState() => _DictadoDialogState();
}

class _DictadoDialogState extends State<_DictadoDialog> {
  final SpeechToText _speech = SpeechToText();

  /// Texto ya consolidado de sesiones anteriores de dictado.
  String _textoBase = '';

  /// Palabras reconocidas en la sesión de dictado en curso.
  String _parcial = '';

  bool _iniciando = true;
  bool _escuchando = false;
  String? _error;
  String? _localeId;

  String get _texto => '$_textoBase$_parcial';

  @override
  void initState() {
    super.initState();
    _textoBase = widget.textoInicial.trim();
    _preparar();
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  Future<void> _preparar() async {
    final disponible = await _speech.initialize(
      onStatus: _onStatus,
      onError: (error) => _mostrarError(
        'No se pudo reconocer la voz. Intenta de nuevo.',
      ),
    );

    if (!mounted) return;

    if (!disponible) {
      // Sin permiso el usuario puede concederlo; sin motor de voz instalado
      // (emuladores sin servicios de Google) no hay nada que hacer.
      final conPermiso = await _speech.hasPermission;
      if (!mounted) return;
      setState(() {
        _iniciando = false;
        _error = conPermiso
            ? 'El reconocimiento de voz no está disponible en este dispositivo.'
            : 'No se pudo acceder al micrófono. Revisa los permisos de la app.';
      });
      return;
    }

    _localeId = await _resolverLocale();
    if (!mounted) return;

    setState(() => _iniciando = false);
    await _escuchar();
  }

  /// Prefiere un locale en español; si el dispositivo no tiene ninguno,
  /// deja que el sistema elija el suyo.
  Future<String?> _resolverLocale() async {
    final locales = await _speech.locales();
    final sistema = await _speech.systemLocale();

    if (sistema != null && sistema.localeId.toLowerCase().startsWith('es')) {
      return sistema.localeId;
    }

    for (final locale in locales) {
      final id = locale.localeId.toLowerCase();
      if (id.startsWith('es_mx') || id.startsWith('es-mx')) {
        return locale.localeId;
      }
    }
    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith('es')) {
        return locale.localeId;
      }
    }
    return sistema?.localeId;
  }

  void _onStatus(String status) {
    if (!mounted) return;
    // En iOS la sesión termina sola tras unos segundos de silencio.
    final escuchando = status == SpeechToText.listeningStatus;
    if (escuchando == _escuchando) return;

    setState(() {
      _escuchando = escuchando;
      if (!escuchando) _consolidarParcial();
    });
  }

  void _consolidarParcial() {
    if (_parcial.isEmpty) return;
    _textoBase = '$_textoBase$_parcial';
    _parcial = '';
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    setState(() {
      _iniciando = false;
      _escuchando = false;
      _error = mensaje;
      _consolidarParcial();
    });
  }

  Future<void> _escuchar() async {
    if (_speech.isListening) return;

    setState(() {
      _error = null;
      _escuchando = true;
    });

    await _speech.listen(
      onResult: _onResult,
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _detener() async {
    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _escuchando = false;
      _consolidarParcial();
    });
  }

  void _onResult(SpeechRecognitionResult resultado) {
    if (!mounted) return;
    setState(() {
      final palabras = resultado.recognizedWords;
      final separador = _textoBase.isEmpty || palabras.isEmpty ? '' : ' ';
      _parcial = '$separador$palabras';
      if (resultado.finalResult) _consolidarParcial();
    });
  }

  void _limpiar() {
    setState(() {
      _textoBase = '';
      _parcial = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final texto = _texto.trim();

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Dictado por voz',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 80, maxHeight: 160),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                reverse: true,
                child: Text(
                  texto.isEmpty ? 'Comienza a hablar...' : texto,
                  style: TextStyle(
                    color: texto.isEmpty ? Colors.black38 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ??
                  (_iniciando
                      ? 'Preparando micrófono...'
                      : _escuchando
                      ? 'Escuchando...'
                      : 'Toca el micrófono para seguir dictando'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _error != null ? Colors.red.shade700 : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Borrar',
                  onPressed: texto.isEmpty ? null : _limpiar,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.black45,
                ),
                const SizedBox(width: 8),
                _buildBotonMicrofono(),
                // Contrapeso del botón de borrar para centrar el micrófono.
                const SizedBox(width: 56),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        TextButton(
          onPressed: texto.isEmpty
              ? null
              : () async {
                  await _speech.stop();
                  if (!context.mounted) return;
                  Navigator.of(context).pop(_texto.trim());
                },
          child: const Text('ACEPTAR'),
        ),
      ],
    );
  }

  Widget _buildBotonMicrofono() {
    if (_iniciando) {
      return const SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _escuchando ? _detener : _escuchar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _escuchando ? widget.acento : Colors.transparent,
          border: Border.all(color: widget.acento, width: 2),
          boxShadow: _escuchando
              ? [
                  BoxShadow(
                    color: widget.acento.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: _escuchando
              ? const Icon(Icons.stop, color: Colors.white, size: 30)
              : Image.asset(widget.iconoMicrofono, width: 36, height: 36),
        ),
      ),
    );
  }
}
