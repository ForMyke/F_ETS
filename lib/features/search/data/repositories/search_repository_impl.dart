import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/network_error_handler.dart';
import '../../domain/entities/exam.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  const SearchRepositoryImpl({required this.remoteDataSource});

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
      return Right(exams);
    } catch (e) {
      return Left(NetworkErrorHandler.handle(e));
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