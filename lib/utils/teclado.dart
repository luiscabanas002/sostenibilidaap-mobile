import 'package:flutter/widgets.dart';

/// Cierra el teclado. Se desenfoca el nodo activo y no el scope de la
/// pantalla: así el input deja de estar en el historial de foco y, al volver
/// de un diálogo, el teclado no reaparece solo.
void ocultarTeclado() => FocusManager.instance.primaryFocus?.unfocus();
