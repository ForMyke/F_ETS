import 'package:etsAndroid/features/catalogs/domain/entities/carrera_item.dart';

class CarreraModel extends CarreraItem {
  const CarreraModel({
    required super.id,
    required super.nombre,
    required super.acronimo,
    required super.activo,
  });

  factory CarreraModel.fromJson(Map<String, dynamic> json) {
    return CarreraModel(
      id: json['id_carrera'] as String,
      nombre: json['nombre'] as String,
      acronimo: json['acronimo'] as String,
      activo: json['activo'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_carrera': id,
        'nombre': nombre,
        'acronimo': acronimo,
        'activo': activo,
      };
}
