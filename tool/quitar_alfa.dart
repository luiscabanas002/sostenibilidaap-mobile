import 'dart:io';
import 'package:image/image.dart' as img;

/// Copia los PNG de un directorio a otro sin canal alfa. App Store Connect
/// rechaza los iconos que lo traen, aunque esté totalmente opaco.
///
/// Uso: `dart run tool/quitar_alfa.dart origen destino`
// ignore_for_file: avoid_print
void main(List<String> args) {
  final destino = Directory(args[1])..createSync(recursive: true);

  for (final archivo in Directory(args[0])
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.png'))) {
    final imagen = img.decodePng(archivo.readAsBytesSync());
    if (imagen == null) continue;

    final sinAlfa = imagen.convert(numChannels: 3);
    final nombre = archivo.uri.pathSegments.last;
    File('${destino.path}/$nombre').writeAsBytesSync(img.encodePng(sinAlfa));
  }
  print('Listo');
}
