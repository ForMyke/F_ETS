part of 'exams_bloc.dart';

abstract class ExamsEvent extends Equatable {
  const ExamsEvent();

  @override
  List<Object?> get props => [];
}

class ExamsStarted extends ExamsEvent {
  const ExamsStarted();
}

class ExamDeleted extends ExamsEvent {
  final String id;
  const ExamDeleted({required this.id});

  @override
  List<Object> get props => [id];
}

class ExamCreated extends ExamsEvent {
  final String carreraMateriaId;
  final String salonId;
  final String periodoId;
  final String jefeId;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const ExamCreated({
    required this.carreraMateriaId,
    required this.salonId,
    required this.periodoId,
    required this.jefeId,
    required this.fechaInicio,
    required this.fechaFin,
  });

  @override
  List<Object> get props => [
    carreraMateriaId,
    salonId,
    periodoId,
    jefeId,
    fechaInicio,
    fechaFin,
  ];
}

class ExamUpdated extends ExamsEvent {
  final String id;
  final String carreraMateriaId;
  final String salonId;
  final String periodoId;
  final String jefeId;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const ExamUpdated({
    required this.id,
    required this.carreraMateriaId,
    required this.salonId,
    required this.periodoId,
    required this.jefeId,
    required this.fechaInicio,
    required this.fechaFin,
  });

  @override
  List<Object> get props => [
    id,
    carreraMateriaId,
    salonId,
    periodoId,
    jefeId,
    fechaInicio,
    fechaFin,
  ];
}