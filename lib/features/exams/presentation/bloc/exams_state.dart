part of 'exams_bloc.dart';

abstract class ExamsState extends Equatable {
  const ExamsState();

  @override
  List<Object?> get props => [];
}

class ExamsInitial extends ExamsState {
  const ExamsInitial();
}

class ExamsLoading extends ExamsState {
  const ExamsLoading();
}

class ExamsSuccess extends ExamsState {
  final List<ExamListItem> exams;
  const ExamsSuccess({required this.exams});

  @override
  List<Object> get props => [exams];
}

class ExamsFailure extends ExamsState {
  final String message;
  const ExamsFailure({required this.message});

  @override
  List<Object> get props => [message];
}