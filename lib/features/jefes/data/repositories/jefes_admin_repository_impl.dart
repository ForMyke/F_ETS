import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/jefes/domain/entities/jefe_admin_item.dart';
import 'package:etsAndroid/features/jefes/domain/entities/academia_item.dart';
import 'package:etsAndroid/features/jefes/domain/repositories/jefes_admin_repository.dart';
import 'package:etsAndroid/features/jefes/data/datasources/jefes_admin_datasource.dart';

class JefesAdminRepositoryImpl implements JefesAdminRepository {
  final JefesAdminDataSource dataSource;

  const JefesAdminRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<JefeAdminItem>>> getJefes() async {
    try {
      final jefes = await dataSource.getJefes();
      return Right(jefes);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar jefes de academia.'));
    }
  }

  @override
  Future<Either<Failure, List<AcademiaItem>>> getAcademias() async {
    try {
      final academias = await dataSource.getAcademias();
      return Right(academias);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar academias.'));
    }
  }

  @override
  Future<Either<Failure, void>> createJefe({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String password,
    required String idAcademia,
  }) async {
    try {
      await dataSource.createJefe(
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        correo: correo,
        password: password,
        idAcademia: idAcademia,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteJefe(String idJefe) async {
    try {
      await dataSource.deleteJefe(idJefe);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar el jefe.'));
    }
  }
}
