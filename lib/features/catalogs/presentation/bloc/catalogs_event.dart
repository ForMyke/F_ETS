part of 'catalogs_bloc.dart';

abstract class CatalogsEvent extends Equatable {
  const CatalogsEvent();

  @override
  List<Object?> get props => [];
}

class CatalogsStarted extends CatalogsEvent {
  const CatalogsStarted();
}

class CarreraCreated extends CatalogsEvent {
  final String nombre;
  final String acronimo;
  const CarreraCreated({required this.nombre, required this.acronimo});

  @override
  List<Object> get props => [nombre, acronimo];
}

class CarreraUpdated extends CatalogsEvent {
  final String id;
  final String nombre;
  final String acronimo;
  final bool activo;
  const CarreraUpdated({required this.id, required this.nombre, required this.acronimo, required this.activo});

  @override
  List<Object> get props => [id, nombre, acronimo, activo];
}

class CarreraDeleted extends CatalogsEvent {
  final String id;
  const CarreraDeleted({required this.id});

  @override
  List<Object> get props => [id];
}

class EdificioCreated extends CatalogsEvent {
  final String numero;
  const EdificioCreated({required this.numero});

  @override
  List<Object> get props => [numero];
}

class EdificioUpdated extends CatalogsEvent {
  final String id;
  final String numero;
  const EdificioUpdated({required this.id, required this.numero});

  @override
  List<Object> get props => [id, numero];
}

class EdificioDeleted extends CatalogsEvent {
  final String id;
  const EdificioDeleted({required this.id});

  @override
  List<Object> get props => [id];
}

class SalonCreated extends CatalogsEvent {
  final String codigo;
  final String piso;
  final String edificioId;
  const SalonCreated({required this.codigo, required this.piso, required this.edificioId});

  @override
  List<Object> get props => [codigo, piso, edificioId];
}

class SalonUpdated extends CatalogsEvent {
  final String id;
  final String codigo;
  final String piso;
  final String edificioId;
  const SalonUpdated({required this.id, required this.codigo, required this.piso, required this.edificioId});

  @override
  List<Object> get props => [id, codigo, piso, edificioId];
}

class SalonDeleted extends CatalogsEvent {
  final String id;
  const SalonDeleted({required this.id});

  @override
  List<Object> get props => [id];
}