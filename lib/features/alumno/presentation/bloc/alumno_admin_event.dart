part of 'alumno_admin_bloc.dart';

abstract class AlumnoAdminEvent extends Equatable {
  const AlumnoAdminEvent();

  @override
  List<Object?> get props => [];
}

class AlumnoAdminStarted extends AlumnoAdminEvent {
  const AlumnoAdminStarted();
}

class AlumnoAdminCreated extends AlumnoAdminEvent {
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String boleta;
  final String password;
  final String idCarrera;
  final String idPlan;

  const AlumnoAdminCreated({
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.boleta,
    required this.password,
    required this.idCarrera,
    required this.idPlan,
  });

  @override
  List<Object?> get props => [correo, boleta, idCarrera, idPlan];
}

class AlumnoAdminToggleActivo extends AlumnoAdminEvent {
  final String idAlumno;
  final bool activo;

  const AlumnoAdminToggleActivo({
    required this.idAlumno,
    required this.activo,
  });

  @override
  List<Object?> get props => [idAlumno, activo];
}

class AlumnoAdminDeleted extends AlumnoAdminEvent {
  final String idAlumno;
  const AlumnoAdminDeleted({required this.idAlumno});

  @override
  List<Object?> get props => [idAlumno];
}

class AlumnoAdminSearchChanged extends AlumnoAdminEvent {
  final String query;
  const AlumnoAdminSearchChanged({required this.query});

  @override
  List<Object?> get props => [query];
}
