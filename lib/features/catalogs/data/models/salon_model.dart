import 'package:etsAndroid/features/catalogs/domain/entities/salon_item.dart';

class SalonModel extends SalonItem {
  const SalonModel({
    required super.id,
    required super.codigo,
    required super.piso,
    required super.edificioId,
    required super.edificioNumero,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    return SalonModel(
      id: json['id_salon'] as String,
      codigo: json['codigo'] as String,
      piso: json['piso'] as String,
      edificioId: json['id_edificio'] as String,
      edificioNumero:
          (json['edificio'] as Map<String, dynamic>)['numero'] as String,
    );
  }
}
