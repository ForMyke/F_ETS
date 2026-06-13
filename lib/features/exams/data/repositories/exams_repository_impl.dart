import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/exams/domain/entities/exam_admin.dart';
import 'package:etsAndroid/features/exams/domain/repositories/exams_repository.dart';
import 'package:etsAndroid/features/exams/data/datasources/exams_remote_datasource.dart';

class ExamsRepositoryImpl implements ExamsRepository {
  final ExamsRemoteDataSource remoteDataSource;

  const ExamsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ExamListItem>>> getExams() async {
    try {
      final exams = await remoteDataSource.getExams();
      return Right(exams);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar exámenes.'));
    }
  }

  @override
  Future<Either<Failure, ExamFormData>> getFormData(
    String? carreraId,
    String? planId,
    String? semestre,
  ) async {
    try {
      final data =
          await remoteDataSource.getFormData(carreraId, planId, semestre);
      return Right(data);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar datos del formulario.'));
    }
  }

  @override
  Future<Either<Failure, void>> createExam({
    required String carreraMateriaId,
    required String salonId,
    required String periodoId,
    required String jefeId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      await remoteDataSource.createExam(
        carreraeMateriaId: carreraMateriaId,
        salonId: salonId,
        periodoId: periodoId,
        jefeId: jefeId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al crear el examen.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateExam({
    required String id,
    required String carreraMateriaId,
    required String salonId,
    required String periodoId,
    required String jefeId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      await remoteDataSource.updateExam(
        id: id,
        carreraMateriaId: carreraMateriaId,
        salonId: salonId,
        periodoId: periodoId,
        jefeId: jefeId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al actualizar el examen.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExam(String id) async {
    try {
      await remoteDataSource.deleteExam(id);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar el examen.'));
    }
  }
}
