import 'package:flutter/material.dart';

import 'pantalla_naranja.dart';

/// Decoración compartida por los campos de las pantallas con fondo naranja.
InputDecoration decoracionCampo({
  required String etiqueta,
  required IconData icono,
  Widget? sufijo,
  String? errorText,
  bool habilitado = true,
}) {
  final colorTexto = habilitado ? Colors.black54 : Colors.black26;

  return InputDecoration(
    labelText: etiqueta,
    errorText: errorText,
    labelStyle: TextStyle(color: colorTexto, fontSize: 17),
    prefixIcon: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Icon(
        icono,
        color: habilitado ? Colors.black : Colors.black26,
        size: 26,
      ),
    ),
    suffixIcon: sufijo,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: habilitado ? Colors.black38 : Colors.black12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.black87, width: 1.5),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
  );
}

/// Campo que abre un diálogo de selección en vez de recibir texto.
class CampoSelector extends StatelessWidget {
  const CampoSelector({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.valor,
    required this.onTap,
    this.habilitado = true,
    this.cargando = false,
    this.error,
  });

  final String etiqueta;
  final IconData icono;
  final String? valor;
  final VoidCallback onTap;
  final bool habilitado;
  final bool cargando;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // El teclado lo cierra showListaPickerDialog al abrirse.
        onTap: habilitado && !cargando ? onTap : null,
        child: InputDecorator(
          isEmpty: valor == null,
          decoration: decoracionCampo(
            etiqueta: etiqueta,
            icono: icono,
            habilitado: habilitado,
            errorText: error,
            sufijo: cargando
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Icon(
                    Icons.arrow_drop_down,
                    color: habilitado ? Colors.black87 : Colors.black26,
                  ),
          ),
          // Siempre hay texto (vacío si no hay selección) para que todos los
          // campos midan lo mismo con y sin valor.
          child: Text(
            valor ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87, fontSize: 17),
          ),
        ),
      ),
    );
  }
}

/// Botón naranja de ancho completo con estado de carga.
class BotonAccion extends StatelessWidget {
  const BotonAccion({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.color = kAcenteNaranja,
  });

  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: cargando ? color : Colors.grey.shade300,
          disabledForegroundColor: cargando ? Colors.white : Colors.grey,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: cargando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                texto,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}

/// Tarjeta blanca redondeada que agrupa contenido sobre el fondo naranja.
class TarjetaBlanca extends StatelessWidget {
  const TarjetaBlanca({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}
