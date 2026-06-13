import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etsAndroid/features/jefes/data/datasources/jefes_admin_datasource.dart';

part 'jefes_admin_event.dart';
part 'jefes_admin_state.dart';

class JefesAdminBloc extends Bloc<JefesAdminEvent, JefesAdminState> {
  final JefesAdminDataSource dataSource;

  JefesAdminBloc({required this.dataSource}) : super(const JefesAdminInitial()) {
    on<JefesAdminStarted>(_onStarted);
    on<JefeAdminCreated>(_onCreated);
    on<JefeAdminDeleted>(_onDeleted);
  }

  Future<void> _reload(Emitter<JefesAdminState> emit) async {
    final jefes = await dataSource.getJefes();
    final academias = await dataSource.getAcademias();
    emit(JefesAdminSuccess(jefes: jefes, academias: academias));
  }

  Future<void> _onStarted(
    JefesAdminStarted event,
    Emitter<JefesAdminState> emit,
  ) async {
    emit(const JefesAdminLoading());
    try {
      await _reload(emit);
    } catch (e) {
      emit(JefesAdminFailure(message: 'Error al cargar jefes: $e'));
    }
  }

  Future<void> _onCreated(
    JefeAdminCreated event,
    Emitter<JefesAdminState> emit,
  ) async {
    emit(const JefesAdminLoading());
    try {
      await dataSource.createJefe(
        nombre: event.nombre,
        apellidoPaterno: event.apellidoPaterno,
        apellidoMaterno: event.apellidoMaterno,
        correo: event.correo,
        password: event.password,
        idAcademia: event.idAcademia,
      );
      await _reload(emit);
    } catch (e) {
      emit(JefesAdminFailure(message: 'Error al crear jefe: $e'));
    }
  }

  Future<void> _onDeleted(
    JefeAdminDeleted event,
    Emitter<JefesAdminState> emit,
  ) async {
    emit(const JefesAdminLoading());
    try {
      await dataSource.deleteJefe(event.idJefe);
      await _reload(emit);
    } catch (e) {
      emit(JefesAdminFailure(message: 'Error al eliminar jefe: $e'));
    }
  }
}
