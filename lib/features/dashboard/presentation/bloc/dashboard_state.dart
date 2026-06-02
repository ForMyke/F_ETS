part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardSuccess extends DashboardState {
  final DashboardStats stats;
  const DashboardSuccess({required this.stats});

  @override
  List<Object> get props => [stats];
}

class DashboardFailure extends DashboardState {
  final String message;
  const DashboardFailure({required this.message});

  @override
  List<Object> get props => [message];
}