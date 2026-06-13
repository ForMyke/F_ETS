import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/exams/domain/entities/exam_admin.dart';
import 'package:etsAndroid/features/exams/domain/repositories/exams_repository.dart';

class GetExamsUseCase implements UseCase<List<ExamListItem>, NoParams> {
  final ExamsRepository repository;
  const GetExamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ExamListItem>>> call(NoParams params) =>
      repository.getExams();
}
