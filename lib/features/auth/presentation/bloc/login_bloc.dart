import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etsAndroid/features/auth/domain/entities/user.dart';
import 'package:etsAndroid/features/auth/domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc({required this.loginUseCase}) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading(isPasswordVisible: state.isPasswordVisible));

    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(LoginFailure(
        message: failure.message,
        isPasswordVisible: state.isPasswordVisible,
      )),
      (user) => emit(LoginSuccess(
        user: user,
        isPasswordVisible: state.isPasswordVisible,
      )),
    );
  }

  void _onPasswordVisibilityToggled(
    LoginPasswordVisibilityToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitial(isPasswordVisible: !state.isPasswordVisible));
  }
}