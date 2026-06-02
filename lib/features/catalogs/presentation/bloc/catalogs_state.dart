part of 'catalogs_bloc.dart';

abstract class CatalogsState extends Equatable {
  const CatalogsState();

  @override
  List<Object?> get props => [];
}

class CatalogsInitial extends CatalogsState {
  const CatalogsInitial();
}

class CatalogsLoading extends CatalogsState {
  const CatalogsLoading();
}

class CatalogsSuccess extends CatalogsState {
  final List<CarreraItem> carreras;
  final List<EdificioItem> edificios;
  final List<SalonItem> salones;

  const CatalogsSuccess({
    required this.carreras,
    required this.edificios,
    required this.salones,
  });

  @override
  List<Object> get props => [carreras, edificios, salones];
}

class CatalogsFailure extends CatalogsState {
  final String message;
  const CatalogsFailure({required this.message});

  @override
  List<Object> get props => [message];
}