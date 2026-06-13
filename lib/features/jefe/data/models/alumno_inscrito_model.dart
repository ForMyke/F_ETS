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
    final alumno = json['alumno'] as Map<String, dynamic>;
    final usuario = alumno['usuario'] as Map<String, dynamic>;
    final nombre =
        '${usuario['nombre']} ${usuario['apellidopaterno']} ${usuario['apellidomaterno']}';

    return AlumnoInscritoModel(
      idInscripcion: json['id_inscripcionets'] as String,
      boleta: alumno['boleta'] as String,
      nombreAlumno: nombre,
      calificacion: (json['calificacion'] as num?)?.toDouble(),
      resultado: json['resultado'] as String?,
      estado: json['estado'] as String,
    );
  }
}
