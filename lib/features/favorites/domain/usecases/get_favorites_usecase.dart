import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../search/domain/entities/exam.dart';
import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase implements UseCase<List<Exam>, NoParams> {
  final FavoritesRepository repository;
  const GetFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Exam>>> call(NoParams params) =>
      repository.getFavorites();
}
