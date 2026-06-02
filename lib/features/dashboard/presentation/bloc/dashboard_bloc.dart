import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRemoteDataSource dataSource;

  DashboardBloc({required this.dataSource}) : super(const DashboardInitial()) {
    on<DashboardStarted>(_onStarted);
  }

  Future<void> _onStarted(
      DashboardStarted event,
      Emitter<DashboardState> emit,
      ) async {
    emit(const DashboardLoading());
    try {
      final stats = await dataSource.getStats();
      emit(DashboardSuccess(stats: stats));
    } catch (e) {
      emit(const DashboardFailure(message: 'Error al cargar estadísticas.'));
    }
  }
}