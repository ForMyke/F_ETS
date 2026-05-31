import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exam.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<Exam>>> getExams({
    String? carrera,
    int? semestre,
    String? plan,
    String? materia,
  });

  Future<Either<Failure, List<String>>> getCarreras();
}