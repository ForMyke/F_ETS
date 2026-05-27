part of 'favorites_bloc.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesSuccess extends FavoritesState {
  final List<Exam> exams;
  const FavoritesSuccess({required this.exams});

  @override
  List<Object> get props => [exams];
}

class FavoritesFailure extends FavoritesState {
  final String message;
  const FavoritesFailure({required this.message});

  @override
  List<Object> get props => [message];
}
