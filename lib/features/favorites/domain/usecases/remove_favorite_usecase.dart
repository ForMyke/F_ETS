import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/favorites/domain/repositories/favorites_repository.dart';

class RemoveFavoriteUseCase implements UseCase<void, RemoveFavoriteParams> {
  final FavoritesRepository repository;
  const RemoveFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFavoriteParams params) =>
      repository.removeFavorite(params.examId);
}

class RemoveFavoriteParams extends Equatable {
  final String examId;
  const RemoveFavoriteParams({required this.examId});

  @override
  List<Object> get props => [examId];
}
