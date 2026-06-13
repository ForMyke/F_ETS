import 'package:equatable/equatable.dart';

class SalonItem extends Equatable {
  final String id;
  final String codigo;
  final String piso;
  final String edificioId;
  final String edificioNumero;

  const SalonItem({
    required this.id,
    required this.codigo,
    required this.piso,
    required this.edificioId,
    required this.edificioNumero,
  });

  @override
  List<Object?> get props => [id, codigo, piso, edificioId, edificioNumero];
}
