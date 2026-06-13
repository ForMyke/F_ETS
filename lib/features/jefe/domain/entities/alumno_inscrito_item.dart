import 'package:equatable/equatable.dart';

class AlumnoInscritoItem extends Equatable {
  final String idInscripcion;
  final String boleta;
  final String nombreAlumno;
  final double? calificacion;
  final String? resultado;
  final String estado;

  const AlumnoInscritoItem({
    required this.idInscripcion,
    required this.boleta,
    required this.nombreAlumno,
    this.calificacion,
    this.resultado,
    required this.estado,
  });

  @override
  List<Object?> get props =>
      [idInscripcion, boleta, nombreAlumno, calificacion, resultado, estado];
}
