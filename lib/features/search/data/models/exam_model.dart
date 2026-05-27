import '../../domain/entities/exam.dart';

class ExamModel extends Exam {
  const ExamModel({
    required super.id,
    required super.materia,
    required super.carrera,
    required super.semestre,
    required super.plan,
    required super.fecha,
    required super.turno,
    required super.hora, // ← nuevo
    required super.salon,
    required super.profesor,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as String,
      materia: json['materia'] as String,
      carrera: json['carrera'] as String,
      semestre: json['semestre'] as int,
      plan: json['plan'] as int,
      fecha: DateTime.parse(json['fecha'] as String),
      turno: json['turno'] as String,
      hora: json['hora'] as String, // ← nuevo
      salon: json['salon'] as String,
      profesor: json['profesor'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'materia': materia,
        'carrera': carrera,
        'semestre': semestre,
        'plan': plan,
        'fecha': fecha.toIso8601String(),
        'turno': turno,
        'hora': hora, // ← nuevo
        'salon': salon,
        'profesor': profesor,
      };
}
