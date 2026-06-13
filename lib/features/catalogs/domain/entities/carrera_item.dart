import 'package:equatable/equatable.dart';

class CarreraItem extends Equatable {
  final String id;
  final String nombre;
  final String acronimo;
  final bool activo;

  const CarreraItem({
    required this.id,
    required this.nombre,
    required this.acronimo,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, acronimo, activo];
}
