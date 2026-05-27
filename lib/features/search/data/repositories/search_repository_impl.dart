import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/exam.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_local_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchLocalDataSource localDataSource;

  const SearchRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Exam>>> getExams({
    String? carrera,
    int? semestre,
    int? plan,
    String? materia,
  }) async {
    try {
      final exams = await localDataSource.getExams(
        carrera: carrera,
        semestre: semestre,
        plan: plan,
        materia: materia,
      );
      return Right(exams);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCarreras() async {
    try {
      final carreras = await localDataSource.getCarreras();
      return Right(carreras);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
