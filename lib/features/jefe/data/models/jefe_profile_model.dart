import 'package:etsAndroid/features/jefe/domain/entities/jefe_profile.dart';

class JefeProfileModel extends JefeProfile {
  const JefeProfileModel({
    required super.idJefe,
    required super.nombre,
    required super.apellidoPaterno,
    required super.apellidoMaterno,
    required super.correo,
  });

  factory JefeProfileModel.fromJson(Map<String, dynamic> json) {
    final u = json['usuario'] as Map<String, dynamic>;
    return JefeProfileModel(
      idJefe: json['id_jefeacademia'] as String,
      nombre: u['nombre'] as String,
      apellidoPaterno: u['apellidopaterno'] as String,
      apellidoMaterno: u['apellidomaterno'] as String,
      correo: u['correo'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_jefeacademia': idJefe,
        'usuario': {
          'nombre': nombre,
          'apellidopaterno': apellidoPaterno,
          'apellidomaterno': apellidoMaterno,
          'correo': correo,
        },
      };
}
