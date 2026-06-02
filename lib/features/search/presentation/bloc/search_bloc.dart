import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/exam.dart';
import '../../domain/usecases/get_exams_usecase.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GetExamsUseCase getExamsUseCase;

  SearchBloc({required this.getExamsUseCase}) : super(const SearchInitial()) {
    on<SearchStarted>(_onStarted);
    on<SearchFiltersChanged>(_onFiltersChanged);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onStarted(
      SearchStarted event,
      Emitter<SearchState> emit,
      ) async {
    emit(const SearchLoading());
    final result = await getExamsUseCase(const GetExamsParams());
    result.fold(
          (failure) {
        if (failure is CachedExamsFailure) {
          emit(SearchSuccess(
            exams: List<Exam>.from(failure.exams),
            fromCache: true,
          ));
        } else {
          emit(SearchFailure(message: failure.message));
        }
      },
          (exams) => emit(SearchSuccess(exams: exams, fromCache: false)),
    );
  }

  Future<void> _onFiltersChanged(
    SearchFiltersChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(
      carrera: event.carrera,
      semestre: event.semestre,
      plan: event.plan,
      materia: event.materia,
    ));
    final result = await getExamsUseCase(GetExamsParams(
      carrera: event.carrera,
      semestre: event.semestre,
      plan: event.plan,
      materia: event.materia,
    ));
    result.fold(
      (failure) => emit(SearchFailure(
        message: failure.message,
        carrera: event.carrera,
        semestre: event.semestre,
        plan: event.plan,
        materia: event.materia,
      )),
      (exams) => emit(SearchSuccess(
        exams: exams,
        carrera: event.carrera,
        semestre: event.semestre,
        plan: event.plan,
        materia: event.materia,
      )),
    );
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchInitial());
  }
}
