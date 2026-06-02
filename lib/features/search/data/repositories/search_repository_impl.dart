import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/network_error_handler.dart';
import '../../domain/entities/exam.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_local_datasource.dart';
import '../datasources/search_remote_datasource.dart';
import '../models/exam_model.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchLocalDataSource localDataSource;

  const SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Exam>>> getExams({
    String? carrera,
    int? semestre,
    String? plan,
    String? materia,
  }) async {
    try {
      final exams = await remoteDataSource.getExams(
        carrera: carrera,
        semestre: semestre,
        plan: plan,
        materia: materia,
      );
      // Cachea solo cuando no hay filtros activos
      if (carrera == null && semestre == null && plan == null && materia == null) {
        await localDataSource.cacheExams(exams.cast<ExamModel>());
      }
      return Right(exams);
    } catch (e) {
      final failure = NetworkErrorHandler.handle(e);
      if (failure is NetworkFailure) {
        final hasCached = await localDataSource.hasCachedExams();
        if (hasCached) {
          final cached = await localDataSource.getCachedExams();
          return Left(CachedExamsFailure(cached));
        }
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCarreras() async {
    try {
      final carreras = await remoteDataSource.getCarreras();
      return Right(carreras);
    } catch (e) {
      return Left(NetworkErrorHandler.handle(e));
    }
  }
}