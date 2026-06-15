import 'package:equatable/equatable.dart';
import 'package:etsAndroid/features/alumno/domain/entities/revision_item.dart';
import 'package:etsAndroid/features/alumno/domain/entities/ets_especial_item.dart';

class InscripcionItem extends Equatable {
  final String idInscripcion;
  final String idEts;
  final String materia;
  final String carrera;
  final String salon;
  final String edificio;
  final DateTime fechaInicio;
  final String hora;
  final String turno;
  final String estado;
  final double? calificacion;
  final String? resultado;
  final RevisionItem? revision;
  final EtsEspecialItem? etsEspecial;

  const InscripcionItem({
    required this.idInscripcion,
    required this.idEts,
    required this.materia,
    required this.carrera,
    required this.salon,
    required this.edificio,
    required this.fechaInicio,
    required this.hora,
    required this.turno,
    required this.estado,
    this.calificacion,
    this.resultado,
    this.revision,
    this.etsEspecial,
  });

  @override
  List<Object?> get props => [
        idInscripcion,
        idEts,
        materia,
        carrera,
        salon,
        edificio,
        fechaInicio,
        hora,
        turno,
        estado,
        calificacion,
        resultado,
        revision,
        etsEspecial,
      ];
}
