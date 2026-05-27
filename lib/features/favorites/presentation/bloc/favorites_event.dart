part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class FavoritesStarted extends FavoritesEvent {
  const FavoritesStarted();
}

class FavoriteAdded extends FavoritesEvent {
  final Exam exam;
  const FavoriteAdded({required this.exam});

  @override
  List<Object> get props => [exam];
}

class FavoriteRemoved extends FavoritesEvent {
  final String examId;
  const FavoriteRemoved({required this.examId});

  @override
  List<Object> get props => [examId];
}
