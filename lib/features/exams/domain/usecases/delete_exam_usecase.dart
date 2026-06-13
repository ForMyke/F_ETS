import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/exams/domain/repositories/exams_repository.dart';

class DeleteExamUseCase implements UseCase<void, String> {
  final ExamsRepository repository;
  const DeleteExamUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteExam(id);
}
