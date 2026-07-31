import 'package:flutter/material.dart';

/// Mensaje informativo del cuestionario (los desMensaje del tipo de factor).
Future<void> showMensajeRegistroDialog(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        titulo,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        child: Text(
          mensaje,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CONTINUAR'),
        ),
      ],
    ),
  );
}

/// Confirmación de dos opciones. Devuelve true solo si se acepta.
Future<bool> showConfirmacionDialog(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String textoNegativo = 'NO',
  String textoPositivo = 'SÍ',
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        titulo,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      content: Text(
        mensaje,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(textoNegativo),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(textoPositivo),
        ),
      ],
    ),
  );

  return confirmado ?? false;
}
