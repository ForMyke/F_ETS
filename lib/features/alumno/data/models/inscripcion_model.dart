import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';

class InscripcionModel extends InscripcionItem {
  const InscripcionModel({
    required super.idInscripcion,
    required super.idEts,
    required super.materia,
    required super.carrera,
    required super.salon,
    required super.edificio,
    required super.fechaInicio,
    required super.hora,
    required super.turno,
    required super.estado,
    super.calificacion,
    super.resultado,
  });

  factory InscripcionModel.fromJson(Map<String, dynamic> json) {
    final ets = json['ets'] as Map<String, dynamic>;
    final salonMap = ets['salon'] as Map<String, dynamic>;
    final cm = ets['carrera_materia'] as Map<String, dynamic>;
    final fechaInicio =
        DateTime.parse(ets['fechahorainicio'] as String);
    final hora =
        '${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')}';

    return InscripcionModel(
      idInscripcion: json['id_inscripcionets'] as String,
      idEts: json['id_ets'] as String,
      materia:
          (cm['materia'] as Map<String, dynamic>)['nombre'] as String,
      carrera:
          (cm['carrera'] as Map<String, dynamic>)['acronimo'] as String,
      salon: salonMap['codigo'] as String,
      edificio:
          (salonMap['edificio'] as Map<String, dynamic>)['numero'] as String,
      fechaInicio: fechaInicio,
      hora: hora,
      turno: ets['turno'] as String? ?? '',
      estado: json['estado'] as String,
      calificacion: (json['calificacion'] as num?)?.toDouble(),
      resultado: json['resultado'] as String?,
    );
  }
}
