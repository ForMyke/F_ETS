part of 'jefes_admin_bloc.dart';

abstract class JefesAdminState extends Equatable {
  const JefesAdminState();

  @override
  List<Object?> get props => [];
}

class JefesAdminInitial extends JefesAdminState {
  const JefesAdminInitial();
}

class JefesAdminLoading extends JefesAdminState {
  const JefesAdminLoading();
}

class JefesAdminSuccess extends JefesAdminState {
  final List<JefeAdminItem> jefes;
  final List<AcademiaItem> academias;

  const JefesAdminSuccess({required this.jefes, required this.academias});

  @override
  List<Object> get props => [jefes, academias];
}

class JefesAdminFailure extends JefesAdminState {
  final String message;
  const JefesAdminFailure({required this.message});

  @override
  List<Object> get props => [message];
}
