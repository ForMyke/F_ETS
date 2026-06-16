import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';
import 'package:etsAndroid/features/alumno/domain/entities/revision_item.dart';
import 'package:etsAndroid/features/alumno/data/models/ets_especial_model.dart';

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
    super.revision,
    super.etsEspecial,
  });

  factory InscripcionModel.fromJson(Map<String, dynamic> json) {
        double? parseDouble(dynamic value) {
            if (value == null) return null;
            if (value is num) return value.toDouble();
            return double.tryParse(value.toString());
        }

        Map<String, dynamic>? firstMap(dynamic value) {
            if (value == null) return null;

            if (value is List) {
            if (value.isEmpty) return null;
            final first = value.first;
            return first is Map<String, dynamic> ? first : null;
            }

            if (value is Map<String, dynamic>) {
            return value;
            }

            return null;
        }

        final ets = (json['ets'] as Map<String, dynamic>?) ?? {};
        final salonMap = (ets['salon'] as Map<String, dynamic>?) ?? {};
        final cm = (ets['carrera_materia'] as Map<String, dynamic>?) ?? {};

        final fechaInicio = DateTime.parse(
            ets['fechahorainicio'] as String? ?? '2000-01-01',
        );

        final hora =
            '${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')}';

        final revMap = firstMap(json['revisionets']);
        final espMap = firstMap(json['etsespecial']);

        return InscripcionModel(
            idInscripcion: json['id_inscripcionets'] as String? ?? '',
            idEts: json['id_ets'] as String? ?? '',
            materia:
                ((cm['materia'] as Map<String, dynamic>?)?['nombre'] as String?) ?? '',
            carrera:
                ((cm['carrera'] as Map<String, dynamic>?)?['acronimo'] as String?) ??
                    '',
            salon: salonMap['codigo'] as String? ?? '',
            edificio:
                ((salonMap['edificio'] as Map<String, dynamic>?)?['numero'])
                        ?.toString() ??
                    '',
            fechaInicio: fechaInicio,
            hora: hora,
            turno: ets['turno'] as String? ?? '',
            estado: json['estado'] as String? ?? '',
            calificacion: parseDouble(json['calificacion']),
            resultado: json['resultado'] as String?,
            revision: revMap != null ? RevisionItem.fromJson(revMap) : null,
            etsEspecial: espMap != null ? EtsEspecialModel.fromJson(espMap) : null,
        );
    }
}
