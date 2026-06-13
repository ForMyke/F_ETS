import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';
import 'package:etsAndroid/features/favorites/domain/repositories/favorites_repository.dart';

class AddFavoriteUseCase implements UseCase<void, AddFavoriteParams> {
  final FavoritesRepository repository;
  const AddFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddFavoriteParams params) =>
      repository.addFavorite(params.exam);
}

class AddFavoriteParams extends Equatable {
  final Exam exam;
  const AddFavoriteParams({required this.exam});

  @override
  List<Object> get props => [exam];
}
