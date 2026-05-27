import 'package:equatable/equatable.dart';

class Exam extends Equatable {
  final String id;
  final String materia;
  final String carrera;
  final int semestre;
  final int plan;
  final DateTime fecha;
  final String turno;
  final String hora; // ← nuevo
  final String salon;
  final String profesor;

  const Exam({
    required this.id,
    required this.materia,
    required this.carrera,
    required this.semestre,
    required this.plan,
    required this.fecha,
    required this.turno,
    required this.hora, // ← nuevo
    required this.salon,
    required this.profesor,
  });

  @override
  List<Object> get props => [
        id,
        materia,
        carrera,
        semestre,
        plan,
        fecha,
        turno,
        hora,
        salon,
        profesor
      ];
}
