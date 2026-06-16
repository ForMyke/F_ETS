import 'package:etsAndroid/features/alumno/domain/entities/alumno_admin_item.dart';

class AlumnoAdminModel extends AlumnoAdminItem {
  const AlumnoAdminModel({
    required super.idAlumno,
    required super.boleta,
    required super.nombre,
    required super.apellidoPaterno,
    required super.apellidoMaterno,
    required super.correo,
    required super.activo,
    required super.idCarrera,
    required super.idPlan,
  });

  factory AlumnoAdminModel.fromJson(Map<String, dynamic> json) {
    final u = json['usuario'] as Map<String, dynamic>;
    return AlumnoAdminModel(
      idAlumno: json['id_alumno'] as String,
      boleta: json['boleta'] as String,
      nombre: u['nombre'] as String,
      apellidoPaterno: u['apellidopaterno'] as String,
      apellidoMaterno: u['apellidomaterno'] as String,
      correo: u['correo'] as String,
      activo: u['activo'] as bool? ?? true,
      idCarrera: json['id_carrera'] as String? ?? '',
      idPlan: json['id_plan'] as String? ?? '',
    );
  }
}
