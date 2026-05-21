part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  final bool isPasswordVisible;
  const LoginState({this.isPasswordVisible = false});

  @override
  List<Object> get props => [isPasswordVisible];
}

class LoginInitial extends LoginState {
  const LoginInitial({super.isPasswordVisible});
}

class LoginLoading extends LoginState {
  const LoginLoading({super.isPasswordVisible});
}

class LoginSuccess extends LoginState {
  final User user;
  const LoginSuccess({required this.user, super.isPasswordVisible});

  @override
  List<Object> get props => [user, isPasswordVisible];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure({required this.message, super.isPasswordVisible});

  @override
  List<Object> get props => [message, isPasswordVisible];
}