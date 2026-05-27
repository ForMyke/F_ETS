import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../search/domain/entities/exam.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<Exam>>> getFavorites();
  Future<Either<Failure, void>> addFavorite(Exam exam);
  Future<Either<Failure, void>> removeFavorite(String examId);
  Future<Either<Failure, bool>> isFavorite(String examId);
}
