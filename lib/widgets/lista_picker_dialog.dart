import 'package:flutter/material.dart';

/// Diálogo genérico para elegir un elemento de una lista, con buscador que
/// filtra conforme se escribe.
Future<T?> showListaPickerDialog<T>(
  BuildContext context, {
  required String titulo,
  required List<T> opciones,
  required String Function(T opcion) etiqueta,
}) {
  // Se quita el foco del input activo (no del scope) antes de abrir: si no,
  // al cerrarse el diálogo el foco regresa a ese input y el teclado reaparece.
  FocusManager.instance.primaryFocus?.unfocus();

  return showDialog<T>(
    context: context,
    builder: (context) {
      var busqueda = '';

      return StatefulBuilder(
        builder: (context, setState) {
          final filtro = busqueda.toLowerCase().trim();
          final filtradas = filtro.isEmpty
              ? opciones
              : opciones
                    .where(
                      (opcion) =>
                          etiqueta(opcion).toLowerCase().contains(filtro),
                    )
                    .toList();

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sin autofocus: el teclado solo sale si tocan el buscador.
                  TextField(
                    onChanged: (value) => setState(() => busqueda = value),
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: filtradas.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Sin resultados',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtradas.length,
                            itemBuilder: (context, index) {
                              final opcion = filtradas[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                title: Text(
                                  etiqueta(opcion),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                onTap: () => Navigator.of(context).pop(opcion),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
