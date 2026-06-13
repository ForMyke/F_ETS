import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/exams/domain/repositories/exams_repository.dart';

class CreateExamParams extends Equatable {
  final String carreraMateriaId;
  final String salonId;
  final String periodoId;
  final String jefeId;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const CreateExamParams({
    required this.carreraMateriaId,
    required this.salonId,
    required this.periodoId,
    required this.jefeId,
    required this.fechaInicio,
    required this.fechaFin,
  });

  @override
  List<Object?> get props =>
      [carreraMateriaId, salonId, periodoId, jefeId, fechaInicio, fechaFin];
}

class CreateExamUseCase implements UseCase<void, CreateExamParams> {
  final ExamsRepository repository;
  const CreateExamUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateExamParams params) =>
      repository.createExam(
        carreraMateriaId: params.carreraMateriaId,
        salonId: params.salonId,
        periodoId: params.periodoId,
        jefeId: params.jefeId,
        fechaInicio: params.fechaInicio,
        fechaFin: params.fechaFin,
      );
}
