import 'package:flutter/material.dart';

import '../core/registro_tema.dart';
import '../models/registro_borrador.dart';
import '../utils/responsive.dart';
import '../widgets/barra_navegacion_registro.dart';
import '../widgets/dialogos_registro.dart';
import '../widgets/dictado_dialog.dart';
import 'resumen_movimientos_screen.dart';

class ComentariosScreen extends StatefulWidget {
  const ComentariosScreen({super.key, required this.borrador});

  static const routeName = '/comentarios';

  final RegistroBorrador borrador;

  @override
  State<ComentariosScreen> createState() => _ComentariosScreenState();
}

class _ComentariosScreenState extends State<ComentariosScreen> {
  static const _textoOscuro = Color(0xFF4A4A4A);

  final TextEditingController _observacionesController =
      TextEditingController();
  final TextEditingController _accionesController = TextEditingController();

  RegistroTema get _tema => RegistroTema.de(widget.borrador.idTipoFactor);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarBienvenida());
  }

  void _mostrarBienvenida() {
    final usuario = widget.borrador.usuario;
    final tipoFactor = usuario.tipoFactorDe(widget.borrador.idTipoFactor);
    if (tipoFactor == null || tipoFactor.desMensaje2.isEmpty) return;

    showMensajeRegistroDialog(
      context,
      titulo: 'Bienvenido: ${usuario.nombre}',
      mensaje: tipoFactor.desMensaje2,
    );
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _accionesController.dispose();
    super.dispose();
  }

  Future<void> _dictar(TextEditingController controller) async {
    final texto = await showDictadoDialog(
      context,
      textoInicial: controller.text,
      acento: _tema.acento,
      iconoMicrofono: _tema.iconoMicro,
    );

    if (texto == null || !mounted) return;

    setState(() {
      controller.text = texto;
      controller.selection = TextSelection.collapsed(offset: texto.length);
    });
  }

  /// Ambos comentarios son opcionales; solo se pide confirmar el envío.
  Future<void> _continuar() async {
    final confirmado = await showConfirmacionDialog(
      context,
      titulo: 'Confirmar',
      mensaje: '¿Desea enviar los datos?',
    );

    if (!confirmado || !mounted) return;

    final observaciones = _observacionesController.text.trim();
    final acciones = _accionesController.text.trim();

    final borrador = widget.borrador.conComentarios(
      observaciones: observaciones.isEmpty ? null : observaciones,
      acciones: acciones.isEmpty ? null : acciones,
    );

    // TODO: enviar el registro y pasar el título con el conteo real.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResumenMovimientosScreen(borrador: borrador),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_tema.fondoAsset(esTablet: context.isTablet)),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  TituloRegistro(_tema.titulo),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        children: [
                          Expanded(
                            child: _buildTarjetaComentario(
                              etiqueta: 'Observaciones',
                              fondo: 'assets/images/ic_observaste.png',
                              controller: _observacionesController,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: _buildTarjetaComentario(
                              etiqueta: 'Acciones a tomar',
                              fondo: 'assets/images/ic_hacer.png',
                              controller: _accionesController,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  BarraNavegacionRegistro(
                    onAtras: () => Navigator.of(context).pop(),
                    onContinuar: _continuar,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTarjetaComentario({
    required String etiqueta,
    required String fondo,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // La imagen de fondo se aclara para que el texto se lea encima.
            Image.asset(fondo, fit: BoxFit.cover),
            Container(color: Colors.white.withValues(alpha: 0.55)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chat, color: Colors.black, size: 30),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          etiqueta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textoOscuro,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildBotonMicrofono(controller),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      cursorColor: _tema.acento,
                      style: const TextStyle(
                        color: _textoOscuro,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _textoOscuro),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _textoOscuro),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonMicrofono(TextEditingController controller) {
    return Material(
      color: _tema.acento,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _dictar(controller),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            'assets/images/iconos/ic_micro_blanco.png',
            width: 30,
            height: 30,
          ),
        ),
      ),
    );
  }
}
