import 'package:etsAndroid/features/catalogs/domain/entities/edificio_item.dart';

class EdificioModel extends EdificioItem {
  const EdificioModel({required super.id, required super.numero});

  factory EdificioModel.fromJson(Map<String, dynamic> json) {
    return EdificioModel(
      id: json['id_edificio'] as String,
      numero: json['numero'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_edificio': id,
        'numero': numero,
      };
}
