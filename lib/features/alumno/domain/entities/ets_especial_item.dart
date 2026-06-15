import 'package:equatable/equatable.dart';
import 'package:etsAndroid/features/alumno/domain/entities/revision_item.dart';

class EtsEspecialItem extends Equatable {
  final String idEtsEspecial;
  final String estado;
  final double? calificacion;
  final String? resultado;
  final RevisionItem? revision;

  const EtsEspecialItem({
    required this.idEtsEspecial,
    required this.estado,
    this.calificacion,
    this.resultado,
    this.revision,
  });

  @override
  List<Object?> get props =>
      [idEtsEspecial, estado, calificacion, resultado, revision];
}
