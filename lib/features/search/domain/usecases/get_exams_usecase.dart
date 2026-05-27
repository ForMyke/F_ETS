import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exam.dart';
import '../repositories/search_repository.dart';

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
  final int? plan;
  final String? materia;

  const GetExamsParams({this.carrera, this.semestre, this.plan, this.materia});

  @override
  List<Object?> get props => [carrera, semestre, plan, materia];
}
