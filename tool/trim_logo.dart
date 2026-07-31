import 'dart:io';

import 'package:image/image.dart' as img;

/// Recorta los márgenes transparentes de un PNG.
/// Uso: `dart run tool/trim_logo.dart ruta.png`
void main(List<String> args) {
  final path = args.first;
  final image = img.decodePng(File(path).readAsBytesSync())!;

  var minX = image.width, minY = image.height, maxX = -1, maxY = -1;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (image.getPixel(x, y).a > 8) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  if (maxX < 0) {
    stderr.writeln('Imagen completamente transparente, no se recorta.');
    exit(1);
  }

  final cropped = img.copyCrop(
    image,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );
  File(path).writeAsBytesSync(img.encodePng(cropped));
  stdout.writeln(
    'Original: ${image.width}x${image.height} -> '
    'Recortada: ${cropped.width}x${cropped.height} '
    '(offsets: x=$minX, y=$minY)',
  );
}
