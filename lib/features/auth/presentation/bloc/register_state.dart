part of 'register_bloc.dart';

abstract class RegisterState extends Equatable {
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const RegisterState({
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  @override
  List<Object> get props => [isPasswordVisible, isConfirmPasswordVisible];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial({
    super.isPasswordVisible,
    super.isConfirmPasswordVisible,
  });
}

class RegisterLoading extends RegisterState {
  const RegisterLoading({
    super.isPasswordVisible,
    super.isConfirmPasswordVisible,
  });
}

class RegisterSuccess extends RegisterState {
  final User user;

  const RegisterSuccess({
    required this.user,
    super.isPasswordVisible,
    super.isConfirmPasswordVisible,
  });

  @override
  List<Object> get props => [user, isPasswordVisible, isConfirmPasswordVisible];
}

class RegisterFailure extends RegisterState {
  final String message;

  const RegisterFailure({
    required this.message,
    super.isPasswordVisible,
    super.isConfirmPasswordVisible,
  });

  @override
  List<Object> get props => [
        message,
        isPasswordVisible,
        isConfirmPasswordVisible,
      ];
}
