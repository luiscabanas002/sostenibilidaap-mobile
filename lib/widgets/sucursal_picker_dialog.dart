import 'package:flutter/material.dart';

import '../models/usuario.dart';

/// Diálogo para elegir una sucursal con buscador de texto que filtra
/// conforme se escribe. Devuelve la sucursal elegida o null.
Future<Sucursal?> showSucursalPickerDialog(
  BuildContext context, {
  required List<Sucursal> sucursales,
}) {
  return showDialog<Sucursal>(
    context: context,
    builder: (context) {
      var query = '';

      return StatefulBuilder(
        builder: (context, setState) {
          final filtered = sucursales
              .where(
                (sucursal) => sucursal.nombre.toLowerCase().contains(
                  query.toLowerCase().trim(),
                ),
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
                  const Text(
                    'Seleccione la planta',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    autofocus: true,
                    onChanged: (value) => setState(() => query = value),
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
                    child: filtered.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Sin resultados',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final sucursal = filtered[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                title: Text(
                                  sucursal.nombre,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                onTap: () =>
                                    Navigator.of(context).pop(sucursal),
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
