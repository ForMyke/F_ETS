import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/jefes/domain/repositories/jefes_admin_repository.dart';

class DeleteJefeUseCase implements UseCase<void, String> {
  final JefesAdminRepository repository;
  const DeleteJefeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String idJefe) =>
      repository.deleteJefe(idJefe);
}
