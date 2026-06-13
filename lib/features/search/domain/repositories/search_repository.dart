import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<Exam>>> getExams({
    String? carrera,
    int? semestre,
    String? plan,
    String? materia,
  });

  Future<Either<Failure, List<String>>> getCarreras();
}