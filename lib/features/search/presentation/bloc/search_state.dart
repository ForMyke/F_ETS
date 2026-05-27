part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  final String? carrera;
  final int? semestre;
  final String? materia;

  const SearchState({this.carrera, this.semestre, this.materia});

  @override
  List<Object?> get props => [carrera, semestre, materia];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading({super.carrera, super.semestre, super.materia});
}

class SearchSuccess extends SearchState {
  final List<Exam> exams;

  const SearchSuccess({
    required this.exams,
    super.carrera,
    super.semestre,
    super.materia,
  });

  @override
  List<Object?> get props => [exams, carrera, semestre, materia];
}

class SearchFailure extends SearchState {
  final String message;

  const SearchFailure({
    required this.message,
    super.carrera,
    super.semestre,
    super.materia,
  });

  @override
  List<Object?> get props => [message, carrera, semestre, materia];
}
