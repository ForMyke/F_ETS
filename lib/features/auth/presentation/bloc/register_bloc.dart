import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etsAndroid/features/auth/domain/entities/user.dart';
import 'package:etsAndroid/features/auth/domain/usecases/register_usecase.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase registerUseCase;

  RegisterBloc({required this.registerUseCase})
      : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<RegisterPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<RegisterConfirmPasswordVisibilityToggled>(
        _onConfirmPasswordVisibilityToggled);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading(
      isPasswordVisible: state.isPasswordVisible,
      isConfirmPasswordVisible: state.isConfirmPasswordVisible,
    ));

    final result = await registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(RegisterFailure(
        message: failure.message,
        isPasswordVisible: state.isPasswordVisible,
        isConfirmPasswordVisible: state.isConfirmPasswordVisible,
      )),
      (user) => emit(RegisterSuccess(
        user: user,
        isPasswordVisible: state.isPasswordVisible,
        isConfirmPasswordVisible: state.isConfirmPasswordVisible,
      )),
    );
  }

  void _onPasswordVisibilityToggled(
    RegisterPasswordVisibilityToggled event,
    Emitter<RegisterState> emit,
  ) {
    emit(RegisterInitial(
      isPasswordVisible: !state.isPasswordVisible,
      isConfirmPasswordVisible: state.isConfirmPasswordVisible,
    ));
  }

  void _onConfirmPasswordVisibilityToggled(
    RegisterConfirmPasswordVisibilityToggled event,
    Emitter<RegisterState> emit,
  ) {
    emit(RegisterInitial(
      isPasswordVisible: state.isPasswordVisible,
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    ));
  }
}
