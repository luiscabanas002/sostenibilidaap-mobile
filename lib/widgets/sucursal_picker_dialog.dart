import 'package:flutter/material.dart';

import '../models/usuario.dart';
import 'lista_picker_dialog.dart';

/// Diálogo para elegir una sucursal con buscador de texto que filtra
/// conforme se escribe. Devuelve la sucursal elegida o null.
Future<Sucursal?> showSucursalPickerDialog(
  BuildContext context, {
  required List<Sucursal> sucursales,
}) {
  return showListaPickerDialog<Sucursal>(
    context,
    titulo: 'Seleccione la planta',
    opciones: sucursales,
    etiqueta: (sucursal) => sucursal.nombre,
  );
}
