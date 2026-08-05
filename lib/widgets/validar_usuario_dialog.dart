import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/division.dart';
import '../models/usuario.dart';
import '../services/division_service.dart';
import '../services/usuario_service.dart';
import 'campos_formulario.dart';
import 'lista_picker_dialog.dart';
import 'pantalla_naranja.dart';

/// Usuario y división con los que se suben los levantamientos guardados.
class UsuarioValidado {
  const UsuarioValidado({required this.usuario, required this.division});

  final Usuario usuario;
  final Division division;
}

/// Pide los mismos datos que el login y devuelve el usuario validado, o null
/// si se cancela. Se usa antes de sincronizar, porque el id_usuario y la
/// división de los levantamientos guardados sin conexión se definen aquí.
Future<UsuarioValidado?> showValidarUsuarioDialog(BuildContext context) {
  return showDialog<UsuarioValidado>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ValidarUsuarioDialog(),
  );
}

class _ValidarUsuarioDialog extends StatefulWidget {
  const _ValidarUsuarioDialog();

  @override
  State<_ValidarUsuarioDialog> createState() => _ValidarUsuarioDialogState();
}

class _ValidarUsuarioDialogState extends State<_ValidarUsuarioDialog> {
  final DivisionService _divisionService = DivisionService();
  final UsuarioService _usuarioService = UsuarioService();
  final TextEditingController _codigoController = TextEditingController();

  Division? _division;
  List<Division> _divisiones = const [];
  bool _cargandoDivisiones = false;
  bool _validando = false;

  /// Se muestra dentro del diálogo: un SnackBar quedaría tapado por él.
  String? _error;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarDivision() async {
    if (_divisiones.isEmpty) {
      setState(() {
        _cargandoDivisiones = true;
      });
      try {
        final divisiones = await _divisionService.getDivisions();
        if (!mounted) return;
        setState(() {
          _divisiones = divisiones;
          _cargandoDivisiones = false;
        });
      } catch (error) {
        if (!mounted) return;
        setState(() {
          _cargandoDivisiones = false;
          _error = 'No se pudieron cargar las divisiones.';
        });
        return;
      }
    }

    if (!mounted) return;
    final seleccion = await showListaPickerDialog<Division>(
      context,
      titulo: 'Seleccione la división',
      opciones: _divisiones,
      etiqueta: (division) => division.descripcion,
    );

    if (seleccion == null || !mounted) return;
    setState(() {
      _division = seleccion;
      _error = null;
    });
  }

  Future<void> _validar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_validando) return;

    final division = _division;
    final clave = _codigoController.text.trim();

    if (division == null || clave.isEmpty) {
      setState(() {
        _error = 'Completa todos los campos.';
      });
      return;
    }

    setState(() {
      _validando = true;
      _error = null;
    });

    try {
      final usuario = await _usuarioService.validarUsuario(
        idDivision: division.idDivision,
        clave: clave,
      );
      if (!mounted) return;
      Navigator.of(context).pop<UsuarioValidado>(
        UsuarioValidado(usuario: usuario, division: division),
      );
    } on ClaveNoEncontradaException catch (error) {
      if (!mounted) return;
      setState(() {
        _validando = false;
        _error = error.mensaje ?? 'No se encontró la clave del empleado';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _validando = false;
        _error = 'No se pudo validar el usuario. Revisa tu conexión.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Validar usuario',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ingresa tu clave para subir los levantamientos guardados a tu '
              'nombre.',
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 20),
            CampoSelector(
              etiqueta: 'División',
              icono: Icons.factory,
              valor: _division?.descripcion,
              cargando: _cargandoDivisiones,
              onTap: _seleccionarDivision,
            ),
            TextField(
              controller: _codigoController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              cursorColor: kAcenteNaranja,
              style: const TextStyle(color: Colors.black87, fontSize: 17),
              decoration: decoracionCampo(
                etiqueta: 'Código',
                icono: Icons.badge,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 14),
              ),
            ],
            const SizedBox(height: 20),
            BotonAccion(
              texto: 'VALIDAR',
              cargando: _validando,
              onPressed: _validar,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: _validando
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text(
                  'CANCELAR',
                  style: TextStyle(color: Colors.black54, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
