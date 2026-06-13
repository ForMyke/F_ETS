import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etsAndroid/features/auth/domain/usecases/reset_password_usecase.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final ResetPasswordUseCase resetPasswordUseCase;

  ResetPasswordBloc({required this.resetPasswordUseCase})
      : super(const ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onSubmitted);
    on<ResetPasswordVisibilityToggled>(_onVisibilityToggled);
    on<ResetPasswordConfirmVisibilityToggled>(_onConfirmVisibilityToggled);
  }

  Future<void> _onSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(ResetPasswordLoading(
      isPasswordVisible: state.isPasswordVisible,
      isConfirmVisible: state.isConfirmVisible,
    ));

    final result = await resetPasswordUseCase(
      ResetPasswordParams(newPassword: event.newPassword),
    );

    result.fold(
      (failure) => emit(ResetPasswordFailure(
        message: failure.message,
        isPasswordVisible: state.isPasswordVisible,
        isConfirmVisible: state.isConfirmVisible,
      )),
      (_) => emit(ResetPasswordSuccess(
        isPasswordVisible: state.isPasswordVisible,
        isConfirmVisible: state.isConfirmVisible,
      )),
    );
  }

  void _onVisibilityToggled(
    ResetPasswordVisibilityToggled event,
    Emitter<ResetPasswordState> emit,
  ) {
    emit(ResetPasswordInitial(
      isPasswordVisible: !state.isPasswordVisible,
      isConfirmVisible: state.isConfirmVisible,
    ));
  }

  void _onConfirmVisibilityToggled(
    ResetPasswordConfirmVisibilityToggled event,
    Emitter<ResetPasswordState> emit,
  ) {
    emit(ResetPasswordInitial(
      isPasswordVisible: state.isPasswordVisible,
      isConfirmVisible: !state.isConfirmVisible,
    ));
  }
}
