import 'package:flutter/material.dart';

import '../models/division.dart';
import '../services/division_service.dart';
import '../services/usuario_service.dart';
import '../utils/responsive.dart';
import '../widgets/option_picker_dialog.dart';
import 'avisos_screen.dart';
import 'formulario_registro_screen.dart';
import 'notificaciones_screen.dart';
import 'registro_usuario_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const List<String> _registerTypes = [
    'Comportamientos',
    'Condiciones',
    'Condiciones Ambientales',
  ];

  static const Color _accentOrange = Color(0xFFEF8140);

  /// Ids de tipo de factor que espera el servicio de usuario.
  static const Map<String, int> _tipoFactorIds = {
    'Comportamientos': 1,
    'Condiciones': 2,
    'Condiciones Ambientales': 3,
  };

  final DivisionService _divisionService = DivisionService();
  final UsuarioService _usuarioService = UsuarioService();
  final TextEditingController _codeController = TextEditingController();

  String? _selectedType;
  Division? _selectedDivision;
  bool _loadingDivisions = false;

  /// Botón que está autenticando: 'code', 'guest' o null si ninguno.
  String? _authAction;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _showRegisterTypePicker() async {
    final selected = await showOptionsDialog(
      context,
      title: 'Seleccione el tipo de registro',
      options: _registerTypes,
    );

    if (selected != null) {
      setState(() => _selectedType = selected);
    }
  }

  Future<void> _showDivisionPicker() async {
    if (_loadingDivisions) return;

    setState(() => _loadingDivisions = true);

    final List<Division> divisions;
    try {
      divisions = await _divisionService.getDivisions();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingDivisions = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudieron cargar las divisiones. Intenta de nuevo.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _loadingDivisions = false);

    final selected = await showOptionsDialog(
      context,
      title: 'Seleccione la división',
      options: divisions.map((division) => division.descripcion).toList(),
    );

    if (selected != null) {
      setState(() {
        _selectedDivision = divisions.firstWhere(
          (division) => division.descripcion == selected,
        );
        _codeController.clear();
      });
    }
  }

  Future<void> _login({required String clave, required String action}) async {
    if (_authAction != null) return;

    final idTipoFactor = _tipoFactorIds[_selectedType];
    final idDivision = _selectedDivision?.idDivision;
    if (idTipoFactor == null || idDivision == null) return;

    setState(() => _authAction = action);

    try {
      final usuario = await _usuarioService.login(
        idTipoFactor: idTipoFactor,
        idDivision: idDivision,
        clave: clave,
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FormularioRegistroScreen(
            usuario: usuario,
            idTipoFactor: idTipoFactor,
            division: _selectedDivision!,
          ),
        ),
      );
    } on ClaveNoEncontradaException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró la clave del empleado')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error al iniciar sesión. Intenta de nuevo.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _authAction = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = context.isTablet
        ? 'assets/images/fondo_naranja1_tablet.png'
        : 'assets/images/fondo_naranja1_mobile.png';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(background),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: 500,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/logo_sostenibilidad.png',
                                  height: 110,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'SOSTENIBILIDAPP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_selectedType == null)
                                  _buildRegisterTypeDropdown()
                                else
                                  _buildSelectionCard(),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildPillButton(
                                        label: 'REGÍSTRATE',
                                        onPressed: () => Navigator.of(
                                          context,
                                        ).pushNamed(
                                          RegistroUsuarioScreen.routeName,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _buildPillButton(
                                        label: 'MODO OFFLINE',
                                        onPressed: () {
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: _buildIconAction(
                                          icon: Icons.notifications,
                                          label: 'Notificaciones',
                                          onTap: () => Navigator.of(
                                            context,
                                          ).pushNamed(
                                            NotificacionesScreen.routeName,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: Center(
                                        child: _buildIconAction(
                                          icon: Icons.campaign,
                                          label: 'Avisos',
                                          onTap: () => Navigator.of(
                                            context,
                                          ).pushNamed(AvisosScreen.routeName),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Image.asset(
                                'assets/images/logo_bepensa.png',
                                height: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterTypeDropdown() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _showRegisterTypePicker,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(
                Icons.assignment_turned_in,
                color: Colors.black,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedType ?? 'Tipo de registro',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, fontSize: 18),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPickerField(
            label: 'Tipo de registro',
            icon: Icons.assignment_turned_in,
            value: _selectedType,
            onTap: _showRegisterTypePicker,
          ),
          const SizedBox(height: 16),
          _buildPickerField(
            label: 'División',
            icon: Icons.factory,
            value: _selectedDivision?.descripcion,
            onTap: _showDivisionPicker,
            loading: _loadingDivisions,
          ),
          if (_selectedDivision != null) ...[
            if (_selectedDivision!.aplicaCodigo == 1) ...[
              const SizedBox(height: 12),
              _buildCodeField(),
              const SizedBox(height: 12),
              _buildValidateCodeButton(),
            ],
            const SizedBox(height: 12),
            _buildGuestButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeField() {
    return TextField(
      controller: _codeController,
      cursorColor: _accentOrange,
      style: const TextStyle(color: Colors.black87, fontSize: 18),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: 'Código',
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 18),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.badge, color: Colors.black, size: 32),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.black87, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.black87, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.black87, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildValidateCodeButton() {
    final hasCode = _codeController.text.trim().isNotEmpty;
    final enabled = hasCode && _authAction == null;

    return _buildAuthButton(
      label: 'VALIDAR CÓDIGO',
      loading: _authAction == 'code',
      onPressed: enabled
          ? () => _login(clave: _codeController.text.trim(), action: 'code')
          : null,
    );
  }

  Widget _buildGuestButton() {
    return _buildAuthButton(
      label: 'INGRESAR COMO INVITADO',
      loading: _authAction == 'guest',
      onPressed: _authAction == null
          ? () => _login(clave: UsuarioService.claveInvitado, action: 'guest')
          : null,
    );
  }

  Widget _buildAuthButton({
    required String label,
    required bool loading,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              loading ? _accentOrange : Colors.grey.shade300,
          disabledForegroundColor: loading ? Colors.white : Colors.grey,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required IconData icon,
    required String? value,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 18),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, color: Colors.black, size: 32),
          ),
          suffixIcon: loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.arrow_drop_down, color: Colors.black87),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Colors.black38),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Colors.black38),
          ),
        ),
        // Siempre se pinta el texto (vacío si no hay selección) para que el
        // campo mida lo mismo con y sin valor; isEmpty controla la etiqueta.
        child: Text(
          value ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black87, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildIconAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 48),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
