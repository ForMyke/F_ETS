import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';
import 'package:etsAndroid/features/favorites/domain/repositories/favorites_repository.dart';

class GetFavoritesUseCase implements UseCase<List<Exam>, NoParams> {
  final FavoritesRepository repository;
  const GetFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Exam>>> call(NoParams params) =>
      repository.getFavorites();
}
