import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/edificio_item.dart';
import 'package:etsAndroid/features/catalogs/domain/repositories/catalogs_repository.dart';

class GetEdificiosUseCase implements UseCase<List<EdificioItem>, NoParams> {
  final CatalogsRepository repository;
  const GetEdificiosUseCase(this.repository);

  @override
  Future<Either<Failure, List<EdificioItem>>> call(NoParams params) =>
      repository.getEdificios();
}
