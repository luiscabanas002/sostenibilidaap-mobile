class Aviso {
  const Aviso({
    required this.idAviso,
    required this.titulo,
    required this.url,
    this.fecha,
  });

  factory Aviso.fromJson(Map<String, dynamic> json) {
    final url = (json['url'] as String? ?? '').trim();

    return Aviso(
      idAviso: json['idAvisos_App'] as int? ?? 0,
      titulo: (json['titulo'] as String? ?? '').trim(),
      // Las rutas del backend traen espacios; hay que codificarlas para Image.network.
      url: url.isEmpty ? '' : Uri.encodeFull(url),
      fecha: DateTime.tryParse(json['fecha'] as String? ?? ''),
    );
  }

  final int idAviso;
  final String titulo;
  final String url;
  final DateTime? fecha;
}
