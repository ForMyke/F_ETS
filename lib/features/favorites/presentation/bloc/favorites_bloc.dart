import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';
import 'package:etsAndroid/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:etsAndroid/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:etsAndroid/features/favorites/domain/usecases/add_favorite_usecase.dart';
import 'package:etsAndroid/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:etsAndroid/features/favorites/domain/usecases/remove_favorite_usecase.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;

  FavoritesBloc({
    required this.getFavoritesUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  }) : super(const FavoritesInitial()) {
    on<FavoritesStarted>(_onStarted);
    on<FavoriteAdded>(_onAdded);
    on<FavoriteRemoved>(_onRemoved);
  }

  static FavoritesBloc create() {
    final ds = FavoritesLocalDataSourceImpl();
    final repo = FavoritesRepositoryImpl(localDataSource: ds);
    return FavoritesBloc(
      getFavoritesUseCase: GetFavoritesUseCase(repo),
      addFavoriteUseCase: AddFavoriteUseCase(repo),
      removeFavoriteUseCase: RemoveFavoriteUseCase(repo),
    );
  }

  Future<void> _onStarted(
    FavoritesStarted event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());
    final result = await getFavoritesUseCase(NoParams());
    result.fold(
      (f) => emit(FavoritesFailure(message: f.message)),
      (exams) => emit(FavoritesSuccess(exams: exams)),
    );
  }

  Future<void> _onAdded(
    FavoriteAdded event,
    Emitter<FavoritesState> emit,
  ) async {
    await addFavoriteUseCase(AddFavoriteParams(exam: event.exam));
    final result = await getFavoritesUseCase(NoParams());
    result.fold(
      (f) => emit(FavoritesFailure(message: f.message)),
      (exams) => emit(FavoritesSuccess(exams: exams)),
    );
  }

  Future<void> _onRemoved(
    FavoriteRemoved event,
    Emitter<FavoritesState> emit,
  ) async {
    await removeFavoriteUseCase(RemoveFavoriteParams(examId: event.examId));
    final result = await getFavoritesUseCase(NoParams());
    result.fold(
      (f) => emit(FavoritesFailure(message: f.message)),
      (exams) => emit(FavoritesSuccess(exams: exams)),
    );
  }
}
