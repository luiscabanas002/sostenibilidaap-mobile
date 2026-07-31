import 'package:flutter/material.dart';

/// Diálogo blanco con una lista simple de opciones. Devuelve la opción
/// seleccionada o null si se cierra sin elegir.
Future<String?> showOptionsDialog(
  BuildContext context, {
  required String title,
  required List<String> options,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: options
          .map(
            (option) => SimpleDialogOption(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              onPressed: () => Navigator.of(context).pop(option),
              child: Text(
                option,
                style: const TextStyle(color: Colors.black87, fontSize: 18),
              ),
            ),
          )
          .toList(),
    ),
  );
}
