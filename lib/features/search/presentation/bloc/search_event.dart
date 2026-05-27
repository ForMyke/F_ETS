part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchStarted extends SearchEvent {
  const SearchStarted();
}

class SearchFiltersChanged extends SearchEvent {
  final String? carrera;
  final int? semestre;
  final String? materia;

  const SearchFiltersChanged({this.carrera, this.semestre, this.materia});

  @override
  List<Object?> get props => [carrera, semestre, materia];
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}
