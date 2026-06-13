import 'package:equatable/equatable.dart';

class AcademiaItem extends Equatable {
  final String idAcademia;
  final String nombre;
  final String acronimo;

  const AcademiaItem({
    required this.idAcademia,
    required this.nombre,
    required this.acronimo,
  });

  @override
  List<Object?> get props => [idAcademia, nombre, acronimo];
}
