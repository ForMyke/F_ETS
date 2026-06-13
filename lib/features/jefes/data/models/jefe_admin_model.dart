import 'package:etsAndroid/features/jefes/domain/entities/jefe_admin_item.dart';

class JefeAdminModel extends JefeAdminItem {
  const JefeAdminModel({
    required super.idJefe,
    required super.nombre,
    required super.apellidoPaterno,
    required super.apellidoMaterno,
    required super.correo,
    super.idAcademia,
    super.nombreAcademia,
  });

  factory JefeAdminModel.fromJson(
    Map<String, dynamic> json, {
    String? idAcademia,
    String? nombreAcademia,
  }) {
    final u = json['usuario'] as Map<String, dynamic>;
    return JefeAdminModel(
      idJefe: json['id_jefeacademia'] as String,
      nombre: u['nombre'] as String,
      apellidoPaterno: u['apellidopaterno'] as String,
      apellidoMaterno: u['apellidomaterno'] as String,
      correo: u['correo'] as String,
      idAcademia: idAcademia,
      nombreAcademia: nombreAcademia,
    );
  }
}
