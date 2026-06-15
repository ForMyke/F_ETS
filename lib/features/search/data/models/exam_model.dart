import 'package:etsAndroid/features/search/domain/entities/exam.dart';

class ExamModel extends Exam {
  const ExamModel({
    required super.id,
    required super.materia,
    required super.carrera,
    required super.semestre,
    required super.plan,
    required super.fechaInicio,
    required super.fechaFin,
    required super.turno,
    required super.hora,
    required super.salon,
    required super.edificio,
    required super.piso,
    required super.profesor,
    required super.periodoETS,
    required super.estado,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    final carreraMateria =
        (json['carrera_materia'] as Map<String, dynamic>?) ?? {};
    final materiaData =
        (carreraMateria['materia'] as Map<String, dynamic>?) ?? {};
    final carreraData =
        (carreraMateria['carrera'] as Map<String, dynamic>?) ?? {};
    final planData =
        (carreraMateria['planestudios'] as Map<String, dynamic>?) ?? {};
    final salonData = (json['salon'] as Map<String, dynamic>?) ?? {};
    final edificioData =
        (salonData['edificio'] as Map<String, dynamic>?) ?? {};
    final jefeData =
        (json['jefeacademia'] as Map<String, dynamic>?) ?? {};
    final usuarioData =
        (jefeData['usuario'] as Map<String, dynamic>?) ?? {};

    final fechaInicio =
        DateTime.parse(json['fechahorainicio'] as String? ?? '2000-01-01');

    final nombreProfesor = [
      usuarioData['nombre'] as String? ?? '',
      usuarioData['apellidopaterno'] as String? ?? '',
      usuarioData['apellidomaterno'] as String? ?? '',
    ].where((s) => s.isNotEmpty).join(' ');

    return ExamModel(
      id: json['id_ets'] as String? ?? '',
      materia: materiaData['nombre'] as String? ?? '',
      carrera: carreraData['acronimo'] as String? ?? '',
      semestre: carreraMateria['semestre'] as int? ?? 0,
      plan: planData['nombre'] as String? ?? '',
      fechaInicio: fechaInicio,
      fechaFin: DateTime.parse(
          json['fechahorafin'] as String? ?? '2000-01-01'),
      turno: json['turno'] as String? ?? '',
      hora:
          '${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')}',
      salon: salonData['codigo'] as String? ?? '',
      edificio: edificioData['numero'] as String? ?? '',
      piso: salonData['piso'] as String? ?? '',
      profesor: nombreProfesor,
      periodoETS: json['id_periodoets'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_ets': id,
        'materia': materia,
        'carrera': carrera,
        'semestre': semestre,
        'plan': plan,
        'fechaHoraInicio': fechaInicio.toIso8601String(),
        'fechaHoraFin': fechaFin.toIso8601String(),
        'turno': turno,
        'hora': hora,
        'salon': salon,
        'edificio': edificio,
        'piso': piso,
        'profesor': profesor,
        'id_periodoETS': periodoETS,
        'estado': estado,
      };
}
