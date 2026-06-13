import 'package:etsAndroid/features/exams/domain/entities/exam_admin.dart';

class ExamListItemModel extends ExamListItem {
  const ExamListItemModel({
    required super.id,
    required super.materia,
    required super.carrera,
    required super.salon,
    required super.salonId,
    required super.edificio,
    required super.turno,
    required super.fechaInicio,
    required super.fechaFin,
    required super.estado,
    required super.periodo,
    required super.profesor,
    required super.jefeId,
    required super.carreraMateriaId,
    required super.carreraId,
    required super.planId,
    required super.semestre,
  });

  factory ExamListItemModel.fromJson(Map<String, dynamic> json) {
    final salon = json['salon'] as Map<String, dynamic>;
    final cm = json['carrera_materia'] as Map<String, dynamic>;
    final jefe = json['jefeacademia'] as Map<String, dynamic>;
    final usuario = jefe['usuario'] as Map<String, dynamic>;
    return ExamListItemModel(
      id: json['id_ets'] as String,
      materia: cm['materia']['nombre'] as String,
      carrera: cm['carrera']['acronimo'] as String,
      salon: salon['codigo'] as String,
      salonId: json['id_salon'] as String,
      edificio: salon['edificio']['numero'] as String,
      turno: json['turno'] as String? ?? '',
      fechaInicio: DateTime.parse(json['fechahorainicio'] as String),
      fechaFin: DateTime.parse(json['fechahorafin'] as String),
      estado: json['estado'] as String,
      periodo: json['id_periodoets'] as String,
      profesor:
          '${usuario['nombre']} ${usuario['apellidopaterno']} ${usuario['apellidomaterno']}',
      jefeId: json['id_jefeacademia'] as String,
      carreraMateriaId: json['id_carrera_materia'] as String,
      carreraId: cm['id_carrera'] as String,
      planId: cm['id_plan'] as String,
      semestre: cm['semestre'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ets': id,
      'fechahorainicio': fechaInicio.toIso8601String(),
      'fechahorafin': fechaFin.toIso8601String(),
      'turno': turno,
      'estado': estado,
      'id_periodoets': periodo,
      'id_salon': salonId,
      'id_carrera_materia': carreraMateriaId,
      'id_jefeacademia': jefeId,
    };
  }
}
