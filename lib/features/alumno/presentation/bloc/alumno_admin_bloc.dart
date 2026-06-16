import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etsAndroid/features/alumno/data/datasources/alumno_admin_datasource.dart';
import 'package:etsAndroid/features/alumno/data/datasources/alumno_remote_datasource.dart';

part 'alumno_admin_event.dart';
part 'alumno_admin_state.dart';

class AlumnosAdminBloc extends Bloc<AlumnoAdminEvent, AlumnoAdminState> {
  final AlumnosAdminDataSource dataSource;
  final AlumnoRemoteDataSource catalogosDataSource;

  AlumnosAdminBloc({
    required this.dataSource,
    required this.catalogosDataSource,
  }) : super(const AlumnoAdminInitial()) {
    on<AlumnoAdminStarted>(_onStarted);
    on<AlumnoAdminCreated>(_onCreated);
    on<AlumnoAdminToggleActivo>(_onToggleActivo);
    on<AlumnoAdminDeleted>(_onDeleted);
    on<AlumnoAdminSearchChanged>(_onSearchChanged);
  }

  Future<void> _reload(
    Emitter<AlumnoAdminState> emit, {
    String query = '',
    List<Map<String, dynamic>>? carreras,
    List<Map<String, dynamic>>? planes,
  }) async {
    final alumnos = await dataSource.getAlumnos();
    final c = carreras ??
        (state is AlumnoAdminSuccess
            ? (state as AlumnoAdminSuccess).carreras
            : <Map<String, dynamic>>[]);
    final p = planes ??
        (state is AlumnoAdminSuccess
            ? (state as AlumnoAdminSuccess).planes
            : <Map<String, dynamic>>[]);
    emit(AlumnoAdminSuccess(
      alumnos: alumnos,
      carreras: c,
      planes: p,
      searchQuery: query,
    ));
  }

  Future<void> _onStarted(
    AlumnoAdminStarted event,
    Emitter<AlumnoAdminState> emit,
  ) async {
    emit(const AlumnoAdminLoading());
    try {
      final results = await Future.wait([
        dataSource.getAlumnos(),
        catalogosDataSource.getCarreras(),
        catalogosDataSource.getPlanes(),
      ]);
      emit(AlumnoAdminSuccess(
        alumnos: results[0] as List<AlumnoAdminItem>,
        carreras: results[1] as List<Map<String, dynamic>>,
        planes: results[2] as List<Map<String, dynamic>>,
      ));
    } catch (e) {
      emit(AlumnoAdminFailure(message: 'Error al cargar datos: $e'));
    }
  }

  Future<void> _onCreated(
    AlumnoAdminCreated event,
    Emitter<AlumnoAdminState> emit,
  ) async {
    final prev =
        state is AlumnoAdminSuccess ? state as AlumnoAdminSuccess : null;
    emit(const AlumnoAdminLoading());
    try {
      await dataSource.createAlumno(
        nombre: event.nombre,
        apellidoPaterno: event.apellidoPaterno,
        apellidoMaterno: event.apellidoMaterno,
        correo: event.correo,
        boleta: event.boleta,
        password: event.password,
        idCarrera: event.idCarrera,
        idPlan: event.idPlan,
      );
      await _reload(
        emit,
        query: prev?.searchQuery ?? '',
        carreras: prev?.carreras,
        planes: prev?.planes,
      );
    } catch (e) {
      emit(AlumnoAdminFailure(message: 'Error al crear alumno: $e'));
    }
  }

  Future<void> _onToggleActivo(
    AlumnoAdminToggleActivo event,
    Emitter<AlumnoAdminState> emit,
  ) async {
    final prev =
        state is AlumnoAdminSuccess ? state as AlumnoAdminSuccess : null;
    try {
      await dataSource.toggleActivo(
          idAlumno: event.idAlumno, activo: event.activo);
      await _reload(
        emit,
        query: prev?.searchQuery ?? '',
        carreras: prev?.carreras,
        planes: prev?.planes,
      );
    } catch (e) {
      emit(AlumnoAdminFailure(message: 'Error al actualizar estado: $e'));
    }
  }

  Future<void> _onDeleted(
    AlumnoAdminDeleted event,
    Emitter<AlumnoAdminState> emit,
  ) async {
    final prev =
        state is AlumnoAdminSuccess ? state as AlumnoAdminSuccess : null;
    emit(const AlumnoAdminLoading());
    try {
      await dataSource.deleteAlumno(event.idAlumno);
      await _reload(
        emit,
        query: prev?.searchQuery ?? '',
        carreras: prev?.carreras,
        planes: prev?.planes,
      );
    } catch (e) {
      emit(AlumnoAdminFailure(message: 'Error al eliminar alumno: $e'));
    }
  }

  void _onSearchChanged(
    AlumnoAdminSearchChanged event,
    Emitter<AlumnoAdminState> emit,
  ) {
    if (state is AlumnoAdminSuccess) {
      emit((state as AlumnoAdminSuccess).copyWith(searchQuery: event.query));
    }
  }
}
