import 'package:equatable/equatable.dart';

class JefeProfile extends Equatable {
  final String idJefe;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;

  const JefeProfile({
    required this.idJefe,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';

  @override
  List<Object?> get props =>
      [idJefe, nombre, apellidoPaterno, apellidoMaterno, correo];
}
