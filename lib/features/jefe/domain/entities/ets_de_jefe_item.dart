import 'package:equatable/equatable.dart';

class EtsDeJefeItem extends Equatable {
  final String idEts;
  final String materia;
  final String carrera;
  final String salon;
  final String edificio;
  final DateTime fechaInicio;
  final String hora;
  final String turno;
  final String estado;

  const EtsDeJefeItem({
    required this.idEts,
    required this.materia,
    required this.carrera,
    required this.salon,
    required this.edificio,
    required this.fechaInicio,
    required this.hora,
    required this.turno,
    required this.estado,
  });

  @override
  List<Object?> get props =>
      [idEts, materia, carrera, salon, edificio, fechaInicio, hora, turno, estado];
}
