import 'package:etsAndroid/features/jefes/domain/entities/academia_item.dart';

class AcademiaModel extends AcademiaItem {
  const AcademiaModel({
    required super.idAcademia,
    required super.nombre,
    required super.acronimo,
  });

  factory AcademiaModel.fromJson(Map<String, dynamic> json) {
    return AcademiaModel(
      idAcademia: json['id_academia'] as String,
      nombre: json['nombre'] as String,
      acronimo: json['acronimo'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_academia': idAcademia,
        'nombre': nombre,
        'acronimo': acronimo,
      };
}
