import 'package:equatable/equatable.dart';

class AlumnoProfile extends Equatable {
  final String idAlumno;
  final String boleta;
  final String idCarrera;
  final String idPlan;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;

  const AlumnoProfile({
    required this.idAlumno,
    required this.boleta,
    required this.idCarrera,
    required this.idPlan,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';

  @override
  List<Object?> get props =>
      [idAlumno, boleta, idCarrera, idPlan, nombre, apellidoPaterno,
       apellidoMaterno, correo];
}
