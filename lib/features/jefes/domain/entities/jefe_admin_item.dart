import 'package:equatable/equatable.dart';

class JefeAdminItem extends Equatable {
  final String idJefe;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String? idAcademia;
  final String? nombreAcademia;

  const JefeAdminItem({
    required this.idJefe,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    this.idAcademia,
    this.nombreAcademia,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';

  @override
  List<Object?> get props =>
      [idJefe, nombre, apellidoPaterno, apellidoMaterno, correo,
       idAcademia, nombreAcademia];
}
