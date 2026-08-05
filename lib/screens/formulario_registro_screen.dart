import 'package:flutter/material.dart';

import '../core/media.dart';
import '../core/registro_tema.dart';
import '../models/division.dart';
import '../models/registro_borrador.dart';
import '../models/usuario.dart';
import '../utils/responsive.dart';
import '../widgets/barra_navegacion_registro.dart';
import '../widgets/dialogos_registro.dart';
import '../widgets/dictado_dialog.dart';
import '../widgets/option_picker_dialog.dart';
import '../widgets/sucursal_picker_dialog.dart';
import 'comentarios_screen.dart';

class FormularioRegistroScreen extends StatefulWidget {
  const FormularioRegistroScreen({
    super.key,
    required this.usuario,
    required this.idTipoFactor,
    required this.division,
  });

  static const routeName = '/formulario-registro';

  final Usuario usuario;
  final int idTipoFactor;
  final Division division;

  @override
  State<FormularioRegistroScreen> createState() =>
      _FormularioRegistroScreenState();
}

class _FormularioRegistroScreenState extends State<FormularioRegistroScreen> {
  static const _iconosPath = 'assets/images/iconos';
  static const _textoOscuro = Color(0xFF4A4A4A);

  final TextEditingController _maquinariaController = TextEditingController();

  final DateTime _fecha = DateTime.now();
  Sucursal? _sucursal;
  String? _tipoComportamiento;
  String? _probabilidadEventoSerio;
  Area? _areaSeleccionada;
  Factor? _factorSeleccionado;

  RegistroTema get _config => RegistroTema.de(widget.idTipoFactor);

  TipoFactor? get _tipoFactor =>
      widget.usuario.tipoFactorDe(widget.idTipoFactor);

  List<Area> get _areas {
    final areas = [...?widget.usuario.info?.areas];
    areas.sort((a, b) => a.numPosicion.compareTo(b.numPosicion));
    return areas;
  }

  List<Factor> get _factores {
    final factores = [...?_tipoFactor?.factores];
    factores.sort((a, b) => a.numPosicion.compareTo(b.numPosicion));
    return factores;
  }

  @override
  void initState() {
    super.initState();

    final sucursales = widget.usuario.info?.sucursales ?? [];
    for (final sucursal in sucursales) {
      if (sucursal.idSucursal == widget.usuario.idSucursal) {
        _sucursal = sucursal;
        break;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarBienvenida());
  }

  @override
  void dispose() {
    _maquinariaController.dispose();
    super.dispose();
  }

  void _mostrarBienvenida() {
    final tipoFactor = _tipoFactor;
    if (tipoFactor == null || tipoFactor.desMensaje1.isEmpty) return;

    showMensajeRegistroDialog(
      context,
      titulo: 'Bienvenido: ${widget.usuario.nombre}',
      mensaje: tipoFactor.desMensaje1,
    );
  }

  Future<void> _seleccionarSucursal() async {
    final seleccion = await showSucursalPickerDialog(
      context,
      sucursales: widget.usuario.info?.sucursales ?? [],
    );
    if (seleccion != null) {
      setState(() => _sucursal = seleccion);
    }
  }

  Future<void> _seleccionarTipoComportamiento() async {
    final seleccion = await showOptionsDialog(
      context,
      title: 'Tipo de comportamiento',
      options: const ['Seguro', 'Inseguro'],
    );
    if (seleccion != null) {
      setState(() => _tipoComportamiento = seleccion);
    }
  }

  Future<void> _seleccionarProbabilidad() async {
    final seleccion = await showOptionsDialog(
      context,
      title: 'Probabilidad de evento serio (SIFp)',
      options: const ['Sí', 'No'],
    );
    if (seleccion != null) {
      setState(() => _probabilidadEventoSerio = seleccion);
    }
  }

  Future<void> _abrirDictado() async {
    final texto = await showDictadoDialog(
      context,
      textoInicial: _maquinariaController.text,
      acento: _config.acento,
      iconoMicrofono: _config.iconoMicro,
    );

    if (texto == null || !mounted) return;

    setState(() {
      _maquinariaController.text = texto;
      _maquinariaController.selection = TextSelection.collapsed(
        offset: texto.length,
      );
    });
  }

  Future<void> _confirmarSalida() async {
    final salir = await showConfirmacionDialog(
      context,
      titulo: '¿Deseas salir del cuestionario?',
      mensaje: 'Se perderá la información capturada.',
      textoNegativo: 'CANCELAR',
      textoPositivo: 'SALIR',
    );

    if (salir && mounted) Navigator.of(context).pop();
  }

  void _continuar() {
    final faltantes = <String>[
      if (_sucursal == null) 'Planta',
      if (_config.muestraSifp && _probabilidadEventoSerio == null)
        'Probabilidad de evento serio (SIFp)',
      if (_tipoComportamiento == null) 'Tipo de comportamiento',
      if (_areaSeleccionada == null) 'Área de observación',
      if (_factorSeleccionado == null) _config.gridTitulo,
    ];

    if (faltantes.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Faltan campos requeridos: ${faltantes.join(', ')}'),
        ),
      );
      return;
    }

    final maquinaria = _maquinariaController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComentariosScreen(
          borrador: RegistroBorrador(
            usuario: widget.usuario,
            idTipoFactor: widget.idTipoFactor,
            division: widget.division,
            fecha: _fecha,
            sucursal: _sucursal!,
            tipoComportamiento: _tipoComportamiento!,
            probabilidadEventoSerio: _probabilidadEventoSerio,
            maquinariaEquipo: maquinaria.isEmpty ? null : maquinaria,
            area: _areaSeleccionada!,
            factor: _factorSeleccionado!,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fondo = _config.fondoAsset(esTablet: context.isTablet);

    final camposSuperiores = <Widget>[
      _buildCampo(
        icono: '$_iconosPath/ic_fecha.png',
        control: _buildControlFecha(),
      ),
      _buildCampo(
        icono: '$_iconosPath/ic_sucursal.png',
        control: _buildSelectorPill(
          label: 'Planta',
          valor: _sucursal?.nombre,
          onTap: _seleccionarSucursal,
        ),
      ),
      if (_config.muestraMaquinaria)
        _buildCampo(
          icono: '$_iconosPath/ic_maquinaria_eq.png',
          control: _buildControlMaquinaria(),
        ),
      if (_config.muestraSifp && _config.sifpAntesDeTipo)
        _buildCampoSifp(),
      _buildCampo(
        icono: '$_iconosPath/ic_comportamiento.png',
        control: _buildSelectorPill(
          label: 'Tipo de comportamiento',
          valor: _tipoComportamiento,
          onTap: _seleccionarTipoComportamiento,
        ),
      ),
      if (_config.muestraSifp && !_config.sifpAntesDeTipo)
        _buildCampoSifp(),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(fondo), fit: BoxFit.cover),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  TituloRegistro(_config.titulo),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ...camposSuperiores,
                          const SizedBox(height: 0),
                          _buildCardAreas(),
                          const SizedBox(height: 8),
                          Expanded(child: _buildCardFactores()),
                        ],
                      ),
                    ),
                  ),
                  BarraNavegacionRegistro(
                    onAtras: _confirmarSalida,
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

  Widget _buildCampoSifp() {
    return _buildCampo(
      icono: '$_iconosPath/ic_maquinaria_eq.png',
      control: _buildSelectorPill(
        label: 'Probabilidad de evento serio (SIFp)',
        valor: _probabilidadEventoSerio,
        onTap: _seleccionarProbabilidad,
      ),
    );
  }

  Widget _buildCampo({required String icono, required Widget control}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Image.asset(icono, height: 30, fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Expanded(child: control),
        ],
      ),
    );
  }

  Widget _buildControlFecha() {
    final dia = _fecha.day.toString().padLeft(2, '0');
    final mes = _fecha.month.toString().padLeft(2, '0');
    final texto = '$dia/$mes/${_fecha.year}';

    // La fecha siempre tiene valor, así que la etiqueta va siempre arriba.
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          labelStyle: TextStyle(color: _textoOscuro, fontSize: 16),
          floatingLabelStyle: TextStyle(color: Colors.black54, fontSize: 18),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(20, 2, 20, 2),
        ),
        child: Text(
          texto,
          style: const TextStyle(color: _textoOscuro, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildControlMaquinaria() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _maquinariaController,
              style: const TextStyle(color: _textoOscuro, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Maquinaria y equipo',
                hintStyle: TextStyle(color: _textoOscuro, fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _abrirDictado,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                '$_iconosPath/ic_micro_verde.png',
                width: 32,
                height: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Selector con etiqueta flotante: mientras no hay valor la etiqueta hace
  /// de hint; al seleccionar, sube en pequeño y deja ver el valor debajo.
  /// La altura es fija para que el formulario no cambie de tamaño.
  Widget _buildSelectorPill({
    required String label,
    required String? valor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: InputDecorator(
            isEmpty: valor == null,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: _textoOscuro, fontSize: 16),
              floatingLabelStyle: const TextStyle(
                color: Colors.black54,
                fontSize: 18,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(12, 2, 4, 2),
              suffixIcon: const Icon(
                Icons.arrow_drop_down,
                color: _textoOscuro,
              ),
            ),
            child: valor == null
                ? null
                : Text(
                    valor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _textoOscuro, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardAreas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'Área de observación',
            style: TextStyle(
              color: _textoOscuro,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _areas.length,
              separatorBuilder: (_, _) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final area = _areas[index];
                final seleccionada =
                    _areaSeleccionada?.idArea == area.idArea;
                return _buildItemIcono(
                  nombre: area.nombre,
                  pathIcono: area.pathIcono,
                  seleccionado: seleccionada,
                  ancho: 90,
                  onTap: () => setState(() => _areaSeleccionada = area),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFactores() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            _config.gridTitulo,
            style: const TextStyle(
              color: _textoOscuro,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisExtent: 112,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
              ),
              itemCount: _factores.length,
              itemBuilder: (context, index) {
                final factor = _factores[index];
                final seleccionado =
                    _factorSeleccionado?.idFactor == factor.idFactor;
                return _buildItemIcono(
                  nombre: factor.nombre,
                  pathIcono: factor.pathIcono,
                  seleccionado: seleccionado,
                  onTap: () => setState(() => _factorSeleccionado = factor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemIcono({
    required String nombre,
    required String pathIcono,
    required bool seleccionado,
    required VoidCallback onTap,
    double? ancho,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: ancho,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: Image.network(
                    mediaUrl(pathIcono),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      '$_iconosPath/ic_default_bepensa.png',
                      width: 56,
                      height: 56,
                    ),
                  ),
                ),
                if (seleccionado)
                  Positioned(
                    top: 0,
                    right: -2,
                    child: Image.asset(
                      '$_iconosPath/ic_salir.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                nombre,
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textoOscuro,
                  fontSize: 11,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
