import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/jefes/domain/entities/jefe_admin_item.dart';
import 'package:etsAndroid/features/jefes/domain/entities/academia_item.dart';

abstract class JefesAdminRepository {
  Future<Either<Failure, List<JefeAdminItem>>> getJefes();

  Future<Either<Failure, List<AcademiaItem>>> getAcademias();

  Future<Either<Failure, void>> createJefe({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String password,
    required String idAcademia,
  });

  Future<Either<Failure, void>> deleteJefe(String idJefe);
}
