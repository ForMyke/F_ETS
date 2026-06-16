import 'package:equatable/equatable.dart';

class AlumnoAdminItem extends Equatable {
  final String idAlumno;
  final String boleta;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final bool activo;
  final String idCarrera;
  final String idPlan;

  const AlumnoAdminItem({
    required this.idAlumno,
    required this.boleta,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.activo,
    required this.idCarrera,
    required this.idPlan,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';

  @override
  List<Object?> get props => [
        idAlumno,
        boleta,
        nombre,
        apellidoPaterno,
        apellidoMaterno,
        correo,
        activo,
        idCarrera,
        idPlan,
      ];
}
