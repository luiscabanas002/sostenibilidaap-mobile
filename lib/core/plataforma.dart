import 'dart:io';

import 'package:flutter/foundation.dart';

/// Etiqueta de sistema operativo que espera el backend en `so`.
String get sistemaOperativo {
  if (!kIsWeb && Platform.isIOS) return 'IOS';
  return 'ANDROID';
}
