import 'package:equatable/equatable.dart';

class Exam extends Equatable {
  final String id;
  final String materia;
  final String carrera;
  final int semestre;
  final String plan;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String turno;
  final String hora;
  final String salon;
  final String edificio;
  final String profesor;
  final String periodoETS;
  final String estado;

  const Exam({
    required this.id,
    required this.materia,
    required this.carrera,
    required this.semestre,
    required this.plan,
    required this.fechaInicio,
    required this.fechaFin,
    required this.turno,
    required this.hora,
    required this.salon,
    required this.edificio,
    required this.profesor,
    required this.periodoETS,
    required this.estado,
  });

  // Mantiene compatibilidad con el código que usa exam.fecha
  DateTime get fecha => fechaInicio;

  @override
  List<Object> get props => [
    id,
    materia,
    carrera,
    semestre,
    plan,
    fechaInicio,
    fechaFin,
    turno,
    hora,
    salon,
    edificio,
    profesor,
    periodoETS,
    estado,
  ];
}