import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';
import 'package:etsAndroid/features/search/domain/repositories/search_repository.dart';

class GetExamsUseCase implements UseCase<List<Exam>, GetExamsParams> {
  final SearchRepository repository;
  const GetExamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Exam>>> call(GetExamsParams params) =>
      repository.getExams(
        carrera: params.carrera,
        semestre: params.semestre,
        plan: params.plan,
        materia: params.materia,
      );
}

class GetExamsParams extends Equatable {
  final String? carrera;
  final int? semestre;
  final String? plan;
  final String? materia;

  const GetExamsParams({this.carrera, this.semestre, this.plan, this.materia});

  @override
  List<Object?> get props => [carrera, semestre, plan, materia];
}