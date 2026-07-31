import 'package:flutter/widgets.dart';

/// Punto de quiebre a partir del cual un dispositivo se considera tablet.
const double kTabletBreakpoint = 600;

/// Utilidades de diseño responsivo para distinguir celular y tablet.
extension ResponsiveContext on BuildContext {
  bool get isTablet => MediaQuery.sizeOf(this).shortestSide >= kTabletBreakpoint;

  bool get isMobile => !isTablet;
}

/// Detecta si el dispositivo es tablet sin necesidad de un [BuildContext].
/// Útil antes de montar el árbol de widgets (por ejemplo en `main`).
bool isTabletDevice() {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
  return shortestSide >= kTabletBreakpoint;
}
