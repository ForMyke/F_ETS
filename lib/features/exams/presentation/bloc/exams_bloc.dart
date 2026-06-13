import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etsAndroid/features/exams/data/datasources/exams_remote_datasource.dart';

part 'exams_event.dart';
part 'exams_state.dart';

class ExamsBloc extends Bloc<ExamsEvent, ExamsState> {
  final ExamsRemoteDataSource dataSource;

  ExamsBloc({required this.dataSource}) : super(const ExamsInitial()) {
    on<ExamsStarted>(_onStarted);
    on<ExamDeleted>(_onDeleted);
    on<ExamCreated>(_onCreated);
    on<ExamUpdated>(_onUpdated);
  }

  Future<void> _onStarted(
      ExamsStarted event,
      Emitter<ExamsState> emit,
      ) async {
    emit(const ExamsLoading());
    try {
      final exams = await dataSource.getExams();
      emit(ExamsSuccess(exams: exams));
    } catch (e) {
      emit(const ExamsFailure(message: 'Error al cargar exámenes.'));
    }
  }

  Future<void> _onDeleted(
      ExamDeleted event,
      Emitter<ExamsState> emit,
      ) async {
    try {
      await dataSource.deleteExam(event.id);
      final exams = await dataSource.getExams();
      emit(ExamsSuccess(exams: exams));
    } catch (e) {
      emit(const ExamsFailure(message: 'Error al eliminar el examen.'));
    }
  }

  Future<void> _onCreated(
      ExamCreated event,
      Emitter<ExamsState> emit,
      ) async {
    try {
      await dataSource.createExam(
        carreraeMateriaId: event.carreraMateriaId,
        salonId: event.salonId,
        periodoId: event.periodoId,
        jefeId: event.jefeId,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );
      final exams = await dataSource.getExams();
      emit(ExamsSuccess(exams: exams));
    } catch (e) {
      emit(const ExamsFailure(message: 'Error al crear el examen.'));
    }
  }

  Future<void> _onUpdated(
      ExamUpdated event,
      Emitter<ExamsState> emit,
      ) async {
    try {
      await dataSource.updateExam(
        id: event.id,
        carreraMateriaId: event.carreraMateriaId,
        salonId: event.salonId,
        periodoId: event.periodoId,
        jefeId: event.jefeId,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );
      final exams = await dataSource.getExams();
      emit(ExamsSuccess(exams: exams));
    } catch (e) {
      emit(const ExamsFailure(message: 'Error al actualizar el examen.'));
    }
  }
}