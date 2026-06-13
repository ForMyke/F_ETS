import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/exams/domain/entities/exam_admin.dart';

abstract class ExamsRepository {
  Future<Either<Failure, List<ExamListItem>>> getExams();

  Future<Either<Failure, ExamFormData>> getFormData(
    String? carreraId,
    String? planId,
    String? semestre,
  );

  Future<Either<Failure, void>> createExam({
    required String carreraMateriaId,
    required String salonId,
    required String periodoId,
    required String jefeId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });

  Future<Either<Failure, void>> updateExam({
    required String id,
    required String carreraMateriaId,
    required String salonId,
    required String periodoId,
    required String jefeId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });

  Future<Either<Failure, void>> deleteExam(String id);
}
