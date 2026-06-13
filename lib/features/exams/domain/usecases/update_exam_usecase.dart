import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/exams/domain/repositories/exams_repository.dart';

class UpdateExamParams extends Equatable {
  final String id;
  final String carreraMateriaId;
  final String salonId;
  final String periodoId;
  final String jefeId;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const UpdateExamParams({
    required this.id,
    required this.carreraMateriaId,
    required this.salonId,
    required this.periodoId,
    required this.jefeId,
    required this.fechaInicio,
    required this.fechaFin,
  });

  @override
  List<Object?> get props =>
      [id, carreraMateriaId, salonId, periodoId, jefeId, fechaInicio, fechaFin];
}

class UpdateExamUseCase implements UseCase<void, UpdateExamParams> {
  final ExamsRepository repository;
  const UpdateExamUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateExamParams params) =>
      repository.updateExam(
        id: params.id,
        carreraMateriaId: params.carreraMateriaId,
        salonId: params.salonId,
        periodoId: params.periodoId,
        jefeId: params.jefeId,
        fechaInicio: params.fechaInicio,
        fechaFin: params.fechaFin,
      );
}
