import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/catalogos_registro.dart';
import '../models/division.dart';
import '../models/proceso.dart';
import '../services/registro_service.dart';
import '../widgets/lista_picker_dialog.dart';
import '../widgets/pantalla_naranja.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  static const routeName = '/registro';

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final RegistroService _service = RegistroService();

  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();

  late Future<CatalogosRegistro> _futuroCatalogos;

  Division? _division;
  Proceso? _proceso;
  SubProceso? _subProceso;
  SucursalProceso? _sucursal;
  Puesto? _puesto;
  String? _pais;

  /// Procesos de la división elegida; vacío mientras no haya división.
  List<Proceso> _procesos = const [];
  bool _cargandoProcesos = false;

  /// Los errores solo se pintan unos segundos tras intentar registrar.
  bool _mostrarErrores = false;
  Timer? _temporizadorErrores;

  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _futuroCatalogos = _service.getCatalogos();
  }

  @override
  void dispose() {
    _temporizadorErrores?.cancel();
    _codigoController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    super.dispose();
  }

  void _recargarCatalogos() {
    final futuro = _service.getCatalogos();
    setState(() {
      _futuroCatalogos = futuro;
    });
  }

  Future<void> _seleccionarDivision(List<Division> divisiones) async {
    final seleccion = await showListaPickerDialog<Division>(
      context,
      titulo: 'Seleccione la división',
      opciones: divisiones,
      etiqueta: (division) => division.descripcion,
    );

    if (seleccion == null || !mounted) return;

    setState(() {
      _ocultarErrores();
      _division = seleccion;
      _procesos = const [];
      _proceso = null;
      _subProceso = null;
      _sucursal = null;
      _cargandoProcesos = true;
    });

    try {
      final procesos = await _service.getProcesos(seleccion.idDivision);
      if (!mounted) return;
      setState(() {
        _procesos = procesos;
        _cargandoProcesos = false;
        _autoSeleccionarProceso();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargandoProcesos = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cargar la información de la división.'),
        ),
      );
    }
  }

  Future<void> _seleccionarProceso() async {
    final seleccion = await showListaPickerDialog<Proceso>(
      context,
      titulo: 'Seleccione el proceso',
      opciones: _procesos,
      etiqueta: (proceso) => proceso.nombre,
    );

    if (seleccion == null || !mounted) return;

    setState(() {
      _ocultarErrores();
      _proceso = seleccion;
      _subProceso = null;
      _sucursal = null;
      _autoSeleccionarSubProceso();
    });
  }

  Future<void> _seleccionarSubProceso() async {
    final seleccion = await showListaPickerDialog<SubProceso>(
      context,
      titulo: 'Seleccione el subproceso',
      opciones: _proceso?.subProcesos ?? const [],
      etiqueta: (subProceso) => subProceso.nombre,
    );

    if (seleccion == null || !mounted) return;

    setState(() {
      _ocultarErrores();
      _subProceso = seleccion;
      _sucursal = null;
      _autoSeleccionarSucursal();
    });
  }

  Future<void> _seleccionarSucursal() async {
    final seleccion = await showListaPickerDialog<SucursalProceso>(
      context,
      titulo: 'Seleccione la sucursal',
      opciones: _subProceso?.sucursales ?? const [],
      etiqueta: (sucursal) => sucursal.nombre,
    );

    if (seleccion == null || !mounted) return;
    setState(() {
      _ocultarErrores();
      _sucursal = seleccion;
    });
  }

  Future<void> _seleccionarPuesto(List<Puesto> puestos) async {
    final seleccion = await showListaPickerDialog<Puesto>(
      context,
      titulo: 'Seleccione el puesto',
      opciones: puestos,
      etiqueta: (puesto) => puesto.nombre,
    );

    if (seleccion == null || !mounted) return;
    setState(() {
      _ocultarErrores();
      _puesto = seleccion;
    });
  }

  Future<void> _seleccionarPais(List<String> paises) async {
    final seleccion = await showListaPickerDialog<String>(
      context,
      titulo: 'Seleccione el país',
      opciones: paises,
      etiqueta: (pais) => pais,
    );

    if (seleccion == null || !mounted) return;
    setState(() {
      _ocultarErrores();
      _pais = seleccion;
    });
  }

  /// Cuando un nivel trae una sola opción se elige solo y se baja al siguiente.
  void _autoSeleccionarProceso() {
    if (_procesos.length != 1) return;
    _proceso = _procesos.first;
    _autoSeleccionarSubProceso();
  }

  void _autoSeleccionarSubProceso() {
    final subProcesos = _proceso?.subProcesos ?? const <SubProceso>[];
    if (subProcesos.length != 1) return;
    _subProceso = subProcesos.first;
    _autoSeleccionarSucursal();
  }

  void _autoSeleccionarSucursal() {
    final sucursales = _subProceso?.sucursales ?? const <SucursalProceso>[];
    if (sucursales.length != 1) return;
    _sucursal = sucursales.first;
  }

  bool get _camposTextoCompletos =>
      _codigoController.text.trim().isNotEmpty &&
      _nombreController.text.trim().isNotEmpty &&
      _apellidosController.text.trim().isNotEmpty;

  bool get _selectoresCompletos =>
      _division != null &&
      _proceso != null &&
      _subProceso != null &&
      _sucursal != null &&
      _puesto != null &&
      _pais != null;

  /// Los avisos desaparecen solos; también al corregir cualquier campo.
  void _ocultarErrores() {
    _temporizadorErrores?.cancel();
    _temporizadorErrores = null;
    _mostrarErrores = false;
  }

  void _mostrarErroresUnosSegundos() {
    _temporizadorErrores?.cancel();
    _mostrarErrores = true;
    _temporizadorErrores = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _mostrarErrores = false;
      });
    });
  }

  Future<void> _registrar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_enviando) return;

    if (!_camposTextoCompletos || !_selectoresCompletos) {
      setState(_mostrarErroresUnosSegundos);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos.'),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      // El backend espera un solo campo de nombre.
      final nombre =
          '${_nombreController.text.trim()} ${_apellidosController.text.trim()}';

      final mensaje = await _service.registrarUsuario(
        clave: _codigoController.text.trim(),
        nombre: nombre,
        pais: _pais!,
        idDivision: _division!.idDivision,
        idProceso: _proceso!.idProceso,
        idSubProceso: _subProceso!.idSubProceso,
        idPuesto: _puesto!.idPuesto,
        idSucursal: _sucursal!.idSucursal,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje ?? 'Registro enviado correctamente.')),
      );
      Navigator.of(context).pop();
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mensajeDeError(error))));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo completar el registro.')),
      );
    }
  }

  /// Si el backend explica el rechazo (clave duplicada, etc.) se muestra tal cual.
  String _mensajeDeError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final mensaje = data['mensaje'] ?? data['message'];
      if (mensaje is String && mensaje.trim().isNotEmpty) return mensaje;
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return 'No se pudo completar el registro.';
  }

  @override
  Widget build(BuildContext context) {
    return PantallaNaranja(titulo: 'Regístrate', child: _buildContenido());
  }

  Widget _buildContenido() {
    return FutureBuilder<CatalogosRegistro>(
      future: _futuroCatalogos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return EstadoPantalla(
            icono: Icons.wifi_off,
            texto: 'No se pudieron cargar los catálogos.',
            onReintentar: _recargarCatalogos,
          );
        }

        return _buildFormulario(snapshot.data!);
      },
    );
  }

  Widget _buildFormulario(CatalogosRegistro catalogos) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildCampoTexto(
              controller: _codigoController,
              etiqueta: 'Código',
              icono: Icons.badge,
              soloDigitos: true,
            ),
            _buildCampoTexto(
              controller: _nombreController,
              etiqueta: 'Nombre',
              icono: Icons.person,
            ),
            _buildCampoTexto(
              controller: _apellidosController,
              etiqueta: 'Apellidos',
              icono: Icons.person_outline,
            ),
            _buildSelector(
              etiqueta: 'División',
              icono: Icons.factory,
              valor: _division?.descripcion,
              onTap: () => _seleccionarDivision(catalogos.divisiones),
            ),
            _buildSelector(
              etiqueta: 'Proceso',
              icono: Icons.account_tree,
              valor: _proceso?.nombre,
              habilitado: _division != null && _procesos.isNotEmpty,
              cargando: _cargandoProcesos,
              onTap: _seleccionarProceso,
            ),
            _buildSelector(
              etiqueta: 'SubProceso',
              icono: Icons.subdirectory_arrow_right,
              valor: _subProceso?.nombre,
              habilitado: _proceso != null,
              onTap: _seleccionarSubProceso,
            ),
            _buildSelector(
              etiqueta: 'Sucursal',
              icono: Icons.store,
              valor: _sucursal?.nombre,
              habilitado: _subProceso != null,
              onTap: _seleccionarSucursal,
            ),
            _buildSelector(
              etiqueta: 'Puesto',
              icono: Icons.work,
              valor: _puesto?.nombre,
              onTap: () => _seleccionarPuesto(catalogos.puestos),
            ),
            _buildSelector(
              etiqueta: 'País',
              icono: Icons.public,
              valor: _pais,
              onTap: () => _seleccionarPais(catalogos.paises),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enviando ? null : _registrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAcenteNaranja,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kAcenteNaranja,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'REGISTRARME',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    bool soloDigitos = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: soloDigitos ? TextInputType.number : TextInputType.text,
        inputFormatters: soloDigitos
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        textCapitalization: soloDigitos
            ? TextCapitalization.none
            : TextCapitalization.words,
        cursorColor: kAcenteNaranja,
        style: const TextStyle(color: Colors.black87, fontSize: 17),
        decoration: _decoracion(etiqueta: etiqueta, icono: icono),
        // Se revalida en cada build para que el aviso se borre solo cuando
        // el temporizador apaga _mostrarErrores.
        autovalidateMode: AutovalidateMode.always,
        validator: (value) {
          if (!_mostrarErrores) return null;
          return (value == null || value.trim().isEmpty)
              ? 'Campo obligatorio'
              : null;
        },
      ),
    );
  }

  Widget _buildSelector({
    required String etiqueta,
    required IconData icono,
    required String? valor,
    required VoidCallback onTap,
    bool habilitado = true,
    bool cargando = false,
  }) {
    // Si el campo está bloqueado el error lo muestra el nivel anterior.
    final error = _mostrarErrores && habilitado && valor == null
        ? 'Campo obligatorio'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // El teclado lo cierra showListaPickerDialog al abrirse.
        onTap: habilitado && !cargando ? onTap : null,
        child: InputDecorator(
          isEmpty: valor == null,
          decoration: _decoracion(
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

  InputDecoration _decoracion({
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
        borderSide: BorderSide(
          color: habilitado ? Colors.black38 : Colors.black12,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black87, width: 1.5),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
