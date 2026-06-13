import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/carrera_item.dart';
import 'package:etsAndroid/features/catalogs/domain/repositories/catalogs_repository.dart';

class GetCarrerasUseCase implements UseCase<List<CarreraItem>, NoParams> {
  final CatalogsRepository repository;
  const GetCarrerasUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarreraItem>>> call(NoParams params) =>
      repository.getCarreras();
}
