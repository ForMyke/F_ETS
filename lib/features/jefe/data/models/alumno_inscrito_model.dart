import 'package:etsAndroid/features/jefe/domain/entities/alumno_inscrito_item.dart';

class AlumnoInscritoModel extends AlumnoInscritoItem {
  const AlumnoInscritoModel({
    required super.idInscripcion,
    required super.boleta,
    required super.nombreAlumno,
    super.calificacion,
    super.resultado,
    required super.estado,
  });

  factory AlumnoInscritoModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    final alumno = json['alumno'] as Map<String, dynamic>? ?? {};
    final usuario = alumno['usuario'] as Map<String, dynamic>? ?? {};

    final nombre = [
      usuario['nombre'],
      usuario['apellidopaterno'],
      usuario['apellidomaterno'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(' ');

    return AlumnoInscritoModel(
      idInscripcion: json['id_inscripcionets'] as String? ?? '',
      boleta: alumno['boleta'] as String? ?? '',
      nombreAlumno: nombre,
      calificacion: parseDouble(json['calificacion']),
      resultado: json['resultado'] as String?,
      estado: json['estado'] as String? ?? '',
    );
  }
}
