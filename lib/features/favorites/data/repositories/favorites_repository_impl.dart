import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/search/data/models/exam_model.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';
import 'package:etsAndroid/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:etsAndroid/features/favorites/data/datasources/favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  const FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Exam>>> getFavorites() async {
    try {
      final favorites = await localDataSource.getFavorites();
      return Right(favorites);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(Exam exam) async {
    try {
      final model = ExamModel(
        id: exam.id,
        materia: exam.materia,
        carrera: exam.carrera,
        semestre: exam.semestre,
        plan: exam.plan,
        fechaInicio: exam.fechaInicio,
        fechaFin: exam.fechaFin,
        turno: exam.turno,
        hora: exam.hora,
        salon: exam.salon,
        edificio: exam.edificio,
        piso: exam.piso,
        profesor: exam.profesor,
        periodoETS: exam.periodoETS,
        estado: exam.estado,
      );
      await localDataSource.addFavorite(model);
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String examId) async {
    try {
      await localDataSource.removeFavorite(examId);
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String examId) async {
    try {
      final result = await localDataSource.isFavorite(examId);
      return Right(result);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
