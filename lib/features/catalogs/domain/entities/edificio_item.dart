import 'package:equatable/equatable.dart';

class EdificioItem extends Equatable {
  final String id;
  final String numero;

  const EdificioItem({required this.id, required this.numero});

  @override
  List<Object?> get props => [id, numero];
}
