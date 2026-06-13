import 'package:etsAndroid/features/jefe/domain/entities/ets_de_jefe_item.dart';

class EtsDeJefeModel extends EtsDeJefeItem {
  const EtsDeJefeModel({
    required super.idEts,
    required super.materia,
    required super.carrera,
    required super.salon,
    required super.edificio,
    required super.fechaInicio,
    required super.hora,
    required super.turno,
    required super.estado,
  });

  factory EtsDeJefeModel.fromJson(Map<String, dynamic> json) {
    final salonMap = json['salon'] as Map<String, dynamic>;
    final cm = json['carrera_materia'] as Map<String, dynamic>;
    final fechaInicio = DateTime.parse(json['fechahorainicio'] as String);
    final hora =
        '${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')}';

    return EtsDeJefeModel(
      idEts: json['id_ets'] as String,
      materia: (cm['materia'] as Map<String, dynamic>)['nombre'] as String,
      carrera: (cm['carrera'] as Map<String, dynamic>)['acronimo'] as String,
      salon: salonMap['codigo'] as String,
      edificio:
          (salonMap['edificio'] as Map<String, dynamic>)['numero'] as String,
      fechaInicio: fechaInicio,
      hora: hora,
      turno: json['turno'] as String? ?? '',
      estado: json['estado'] as String,
    );
  }
}
