part of 'jefes_admin_bloc.dart';

abstract class JefesAdminEvent extends Equatable {
  const JefesAdminEvent();

  @override
  List<Object?> get props => [];
}

class JefesAdminStarted extends JefesAdminEvent {
  const JefesAdminStarted();
}

class JefeAdminCreated extends JefesAdminEvent {
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String password;
  final String idAcademia;

  const JefeAdminCreated({
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.password,
    required this.idAcademia,
  });

  @override
  List<Object> get props => [correo, idAcademia];
}

class JefeAdminDeleted extends JefesAdminEvent {
  final String idJefe;
  const JefeAdminDeleted({required this.idJefe});

  @override
  List<Object> get props => [idJefe];
}
