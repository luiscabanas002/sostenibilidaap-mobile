import '../core/network/api_client.dart';
import '../core/plataforma.dart';
import '../core/registro_tema.dart';
import '../models/registro_borrador.dart';
import 'push_service.dart';

class LevantamientoService {
  /// Envía el levantamiento capturado. Devuelve el mensaje del backend, que
  /// es el que se muestra en la pantalla de resumen.
  Future<String?> registrar(RegistroBorrador borrador) async {
    final tema = RegistroTema.de(borrador.idTipoFactor);
    final token = await PushService.instance.obtenerToken() ?? '';
    final maquinaEquipo = _maquinaEquipo(borrador, tema);
    final aplicaSucursal = borrador.division.aplicaSucursal == 1;

    final response = await ApiClient.dio.post<Map<String, dynamic>>(
      '/Levantamiento/Registrar',
      data: {
        'id_usuario': borrador.usuario.idUsuario,
        'id_area': borrador.area.idArea,
        'id_factor': borrador.factor.idFactor,
        'id_origen_observacion': 2,
        // Sin sucursal aplicable el backend recibe -1 y el nombre en null.
        'id_sucursal': aplicaSucursal ? borrador.sucursal.idSucursal : -1,
        // Ambos campos llevan el mismo valor; el backend guarda el que
        // corresponde a la tabla del tipo de levantamiento.
        'maquina_equipo': maquinaEquipo,
        'maquina_equipo_zona': maquinaEquipo,
        'observaciones': borrador.observaciones ?? '',
        'acciones_a_tomar': borrador.acciones ?? '',
        'id_division': borrador.division.idDivision,
        'adicional_suc': aplicaSucursal ? borrador.sucursal.nombre : null,
        'fecha_hora_registro': borrador.fecha.toIso8601String(),
        'atendido': false,
        'token': token,
        'so': sistemaOperativo,
        'tipo_comportamiento': _tipoComportamiento(borrador),
        'tipo_levantamiento': tema.tipoLevantamiento,
      },
    );

    return response.data?['mensaje'] as String?;
  }

  /// El backend guarda este campo como entero.
  String _tipoComportamiento(RegistroBorrador borrador) {
    return borrador.tipoComportamiento == 'Seguro' ? '0' : '1';
  }

  /// En TOC y Condiciones este campo lleva la probabilidad de evento serio
  /// (SIFp); solo en Ambiental lleva el texto de maquinaria y equipo.
  String _maquinaEquipo(RegistroBorrador borrador, RegistroTema tema) {
    if (tema.muestraMaquinaria) return borrador.maquinariaEquipo ?? '';
    return borrador.probabilidadEventoSerio ?? '';
  }
}
