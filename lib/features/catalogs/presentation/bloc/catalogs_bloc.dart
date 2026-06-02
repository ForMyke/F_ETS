import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/catalogs_remote_datasource.dart';

part 'catalogs_event.dart';
part 'catalogs_state.dart';

class CatalogsBloc extends Bloc<CatalogsEvent, CatalogsState> {
  final CatalogsRemoteDataSource dataSource;

  CatalogsBloc({required this.dataSource}) : super(const CatalogsInitial()) {
    on<CatalogsStarted>(_onStarted);
    on<CarreraCreated>(_onCarreraCreated);
    on<CarreraUpdated>(_onCarreraUpdated);
    on<CarreraDeleted>(_onCarreraDeleted);
    on<EdificioCreated>(_onEdificioCreated);
    on<EdificioUpdated>(_onEdificioUpdated);
    on<EdificioDeleted>(_onEdificioDeleted);
    on<SalonCreated>(_onSalonCreated);
    on<SalonUpdated>(_onSalonUpdated);
    on<SalonDeleted>(_onSalonDeleted);
  }

  Future<void> _reload(Emitter<CatalogsState> emit) async {
    final carreras = await dataSource.getCarreras();
    final edificios = await dataSource.getEdificios();
    final salones = await dataSource.getSalones();
    emit(CatalogsSuccess(
      carreras: carreras,
      edificios: edificios,
      salones: salones,
    ));
  }

  Future<void> _onStarted(CatalogsStarted event, Emitter<CatalogsState> emit) async {
    emit(const CatalogsLoading());
    try {
      await _reload(emit);
    } catch (e) {
      emit(const CatalogsFailure(message: 'Error al cargar catálogos.'));
    }
  }

  Future<void> _onCarreraCreated(CarreraCreated event, Emitter<CatalogsState> emit) async {
    try {
      await dataSource.createCarrera(nombre: event.nombre, acronimo: event.acronimo);
      await _reload(emit);
    } catch (e) {
      emit(const CatalogsFailure(message: 'Error al crear carrera.'));
    }
  }

  Future<void> _onCarreraUpdated(CarreraUpdated event, Emitter<CatalogsState> emit) async {
    try {
      await dataSource.updateCarrera(
        id: event.id,
        nombre: event.nombre,
        acronimo: event.acronimo,
        activo: event.activo,
      );
      await _reload(emit);
    } catch (e) {
      emit(const CatalogsFailure(message: 'Error al actualizar carrera.'));
    }
  }

  Future<void> _onCarreraDeleted(CarreraDeleted event, Emitter<CatalogsState> emit) async {
    try {
      await dataSource.deleteCarrera(event.id);
      await _reload(emit);
    } catch (e) {
      emit(const CatalogsFailure(message: 'Error al eliminar carrera.'));
    }
  }

  Future<void> _onEdificioCreated(EdificioCreated event, Emitter<CatalogsState> emit) async {
    try {
      await dataSource.createEdificio(numero: event.numero);
      await _reload(emit);
    } catch (e) {
      emit(const CatalogsFailure(message: 'Error al crear edificio.'));
    }
  }

  Future<void> _onEdificioUpdated(EdificioUpdated event, Emitter<CatalogsState> emit) async {
    try {
      await dataSource.updateEdificio(id: event.id, numero: event.numero);
      await _reload(emit);
    } catch (e) {
      emit(const CatalogsFailure(message: 'Error al actualizar edificio.'));
    }
  }

  Future<void> _onEdificioDeleted(EdificioDeleted event, Emitter<CatalogsState> emit) async {
    try {
      await dataSource.deleteEdificio(event.id);
      await _reload(emit);
    } catch (e) {
      emit(const CatalogsFailure(message: 'Error al eliminar edificio.'));
    }
  }

  Future<void> _onSalonCreated(SalonCreated event, Emitter<CatalogsState> emit) async {
    try {
      await dataSource.createSalon(
        codigo: event.codigo,
        piso: event.piso,
        edificioId: event.edificioId,
      );
      await _reload(emit);
    } catch (e) {
      emit(const CatalogsFailure(message: 'Error al crear salón.'));
    }
  }

  Future<void> _onSalonUpdated(SalonUpdated event, Emitter<CatalogsState> emit) async {
    try {
      await dataSource.updateSalon(
        id: event.id,
        codigo: event.codigo,
        piso: event.piso,
        edificioId: event.edificioId,
      );
      await _reload(emit);
    } catch (e) {
      emit(const CatalogsFailure(message: 'Error al actualizar salón.'));
    }
  }

  Future<void> _onSalonDeleted(SalonDeleted event, Emitter<CatalogsState> emit) async {
    try {
      await dataSource.deleteSalon(event.id);
      await _reload(emit);
    } catch (e) {
      emit(const CatalogsFailure(message: 'Error al eliminar salón.'));
    }
  }
}