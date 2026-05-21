part of 'reset_password_bloc.dart';

abstract class ResetPasswordState extends Equatable {
  final bool isPasswordVisible;
  final bool isConfirmVisible;

  const ResetPasswordState({
    this.isPasswordVisible = false,
    this.isConfirmVisible = false,
  });

  @override
  List<Object> get props => [isPasswordVisible, isConfirmVisible];
}

class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial({
    super.isPasswordVisible,
    super.isConfirmVisible,
  });
}

class ResetPasswordLoading extends ResetPasswordState {
  const ResetPasswordLoading({
    super.isPasswordVisible,
    super.isConfirmVisible,
  });
}

class ResetPasswordSuccess extends ResetPasswordState {
  const ResetPasswordSuccess({
    super.isPasswordVisible,
    super.isConfirmVisible,
  });
}

class ResetPasswordFailure extends ResetPasswordState {
  final String message;
  const ResetPasswordFailure({
    required this.message,
    super.isPasswordVisible,
    super.isConfirmVisible,
  });

  @override
  List<Object> get props => [message, isPasswordVisible, isConfirmVisible];
}
