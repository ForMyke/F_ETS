import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';

class AlumnoProfileModel extends AlumnoProfile {
  const AlumnoProfileModel({
    required super.idAlumno,
    required super.boleta,
    required super.idCarrera,
    required super.idPlan,
    required super.nombre,
    required super.apellidoPaterno,
    required super.apellidoMaterno,
    required super.correo,
  });

  factory AlumnoProfileModel.fromJson(Map<String, dynamic> json) {
    final u = json['usuario'] as Map<String, dynamic>;
    return AlumnoProfileModel(
      idAlumno: json['id_alumno'] as String,
      boleta: json['boleta'] as String,
      idCarrera: json['id_carrera'] as String,
      idPlan: json['id_plan'] as String,
      nombre: u['nombre'] as String,
      apellidoPaterno: u['apellidopaterno'] as String,
      apellidoMaterno: u['apellidomaterno'] as String,
      correo: u['correo'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_alumno': idAlumno,
        'boleta': boleta,
        'id_carrera': idCarrera,
        'id_plan': idPlan,
        'usuario': {
          'nombre': nombre,
          'apellidopaterno': apellidoPaterno,
          'apellidomaterno': apellidoMaterno,
          'correo': correo,
        },
      };
}
