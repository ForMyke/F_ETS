part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  final String? carrera;
  final int? semestre;
  final String? plan;
  final String? materia;

  const SearchState({this.carrera, this.semestre, this.plan, this.materia});

  @override
  List<Object?> get props => [carrera, semestre, plan, materia];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading({
    super.carrera,
    super.semestre,
    super.plan,
    super.materia,
  });
}

class SearchSuccess extends SearchState {
  final List<Exam> exams;
  final bool fromCache;

  const SearchSuccess({
    required this.exams,
    this.fromCache = false,
    super.carrera,
    super.semestre,
    super.plan,
    super.materia,
  });

  @override
  List<Object?> get props => [exams, fromCache, carrera, semestre, plan, materia];
}

class SearchFailure extends SearchState {
  final String message;

  const SearchFailure({
    required this.message,
    super.carrera,
    super.semestre,
    super.plan,
    super.materia,
  });

  @override
  List<Object?> get props => [message, carrera, semestre, plan, materia];
}