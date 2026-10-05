import '../flavors.dart';
import 'registro_tema.dart';

/// Valores que cambian según el flavor (bepensa/tijuana): marca, textos y
/// backend. Todo lo demás (lógica, pantallas, backend contract) es igual.
class FlavorConfig {
  const FlavorConfig({
    required this.appName,
    required this.logoAsset,
    required this.defaultFactorIconAsset,
    required this.splashFallbackText,
    required this.serverBaseUrl,
    required this.notificationChannelName,
    required this.notificationChannelDescription,
    required this.graciasMensaje,
    required this.divisionLabel,
    required this.codigoLabel,
    required this.validarCodigoLabel,
    required this.modoOfflineTitulo,
    required this.modoOfflineBoton,
    required this.useSolidBackgrounds,
    this.tituloPorTipoFactor = const {},
    this.gridTituloPorTipoFactor = const {},
  });

  final String appName;
  final String logoAsset;
  final String defaultFactorIconAsset;
  final String splashFallbackText;
  final String serverBaseUrl;
  final String notificationChannelName;
  final String notificationChannelDescription;
  final String graciasMensaje;
  final String divisionLabel;
  final String codigoLabel;
  final String validarCodigoLabel;
  final String modoOfflineTitulo;
  final String modoOfflineBoton;

  /// En tijuana los fondos de RegistroTema son color sólido en vez de imagen.
  final bool useSolidBackgrounds;

  final Map<int, String> tituloPorTipoFactor;
  final Map<int, String> gridTituloPorTipoFactor;

  /// Aplica los textos de este flavor sobre un [RegistroTema] base.
  RegistroTema aplicarTextos(RegistroTema base, int idTipoFactor) {
    final titulo = tituloPorTipoFactor[idTipoFactor];
    final gridTitulo = gridTituloPorTipoFactor[idTipoFactor];
    if (titulo == null && gridTitulo == null) return base;
    return base.copyWith(titulo: titulo, gridTitulo: gridTitulo);
  }

  static const _bepensa = FlavorConfig(
    appName: 'Sostenibilidapp',
    logoAsset: 'assets/images/logo_bepensa.png',
    defaultFactorIconAsset: 'assets/images/iconos/ic_default_bepensa.png',
    splashFallbackText: 'Bepensa\n#UnidosPodemos',
    serverBaseUrl: 'http://app.bepensa-web.com:802',
    notificationChannelName: 'Avisos',
    notificationChannelDescription: 'Avisos y recordatorios de Sostenibilidapp.',
    graciasMensaje:
        'Gracias por hacer de Bepensa un lugar más seguro para trabajar.',
    divisionLabel: 'División',
    codigoLabel: 'Código',
    validarCodigoLabel: 'VALIDAR CÓDIGO',
    modoOfflineTitulo: 'Modo offline',
    modoOfflineBoton: 'MODO OFFLINE',
    useSolidBackgrounds: false,
  );

  static const _tijuana = FlavorConfig(
    appName: 'Reporta-CDF',
    logoAsset: 'assets/images/logo_tijuana.png',
    defaultFactorIconAsset: 'assets/images/iconos/ic_default_tijuana.png',
    splashFallbackText: 'Reporta-CDF\n#UnidosPodemos',
    serverBaseUrl: 'http://app.bepensa-web.com:802',
    notificationChannelName: 'Avisos',
    notificationChannelDescription: 'Avisos y recordatorios de Reporta-CDF.',
    graciasMensaje:
        'Gracias por hacer de CDF un lugar más seguro para trabajar.',
    divisionLabel: 'Franquicia',
    codigoLabel: 'Número de empleado',
    validarCodigoLabel: 'INGRESAR',
    modoOfflineTitulo: 'Modo invitado',
    modoOfflineBoton: 'MODO INVITADO',
    useSolidBackgrounds: true,
    tituloPorTipoFactor: {1: 'Registro de comportamientos'},
    gridTituloPorTipoFactor: {3: 'Aspecto ambiental'},
  );

  static FlavorConfig get current {
    switch (F.appFlavor) {
      case Flavor.bepensa:
        return _bepensa;
      case Flavor.tijuana:
        return _tijuana;
    }
  }
}
