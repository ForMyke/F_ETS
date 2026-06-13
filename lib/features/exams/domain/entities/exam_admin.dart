import 'package:equatable/equatable.dart';

/// Datos de catálogos usados para poblar el formulario de creación/edición de ETS.
class ExamFormData extends Equatable {
  final List<Map<String, dynamic>> carreras;
  final List<Map<String, dynamic>> planes;
  final List<Map<String, dynamic>> materias;
  final List<Map<String, dynamic>> salones;
  final List<Map<String, dynamic>> periodos;
  final List<Map<String, dynamic>> jefes;

  const ExamFormData({
    required this.carreras,
    required this.planes,
    required this.materias,
    required this.salones,
    required this.periodos,
    required this.jefes,
  });

  @override
  List<Object?> get props =>
      [carreras, planes, materias, salones, periodos, jefes];
}

/// Un ETS tal como lo administra un jefe/admin en la sección de exámenes.
class ExamListItem extends Equatable {
  final String id;
  final String materia;
  final String carrera;
  final String salon;
  final String salonId;
  final String edificio;
  final String turno;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
  final String periodo;
  final String profesor;
  final String jefeId;
  final String carreraMateriaId;
  final String carreraId;
  final String planId;
  final int semestre;

  const ExamListItem({
    required this.id,
    required this.materia,
    required this.carrera,
    required this.salon,
    required this.salonId,
    required this.edificio,
    required this.turno,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.periodo,
    required this.profesor,
    required this.jefeId,
    required this.carreraMateriaId,
    required this.carreraId,
    required this.planId,
    required this.semestre,
  });

  @override
  List<Object?> get props => [
        id,
        materia,
        carrera,
        salon,
        salonId,
        edificio,
        turno,
        fechaInicio,
        fechaFin,
        estado,
        periodo,
        profesor,
        jefeId,
        carreraMateriaId,
        carreraId,
        planId,
        semestre,
      ];
}
