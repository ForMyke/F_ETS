import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/presentation/bloc/forgot_password_bloc.dart';
import '../../features/auth/presentation/bloc/login_bloc.dart';
import '../../features/auth/presentation/bloc/register_bloc.dart';
import '../../features/auth/presentation/bloc/reset_password_bloc.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';

  static AuthRepositoryImpl _buildRepo() => AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(client: http.Client()),
      );

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case register:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => RegisterBloc(
              registerUseCase: RegisterUseCase(_buildRepo()),
            ),
            child: const RegisterPage(),
          ),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ForgotPasswordBloc(
              forgotPasswordUseCase: ForgotPasswordUseCase(_buildRepo()),
            ),
            child: const ForgotPasswordPage(),
          ),
        );

      case resetPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ResetPasswordBloc(
              resetPasswordUseCase: ResetPasswordUseCase(_buildRepo()),
            ),
            child: const ResetPasswordPage(),
          ),
        );

      case login:
      default:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => LoginBloc(
              loginUseCase: LoginUseCase(_buildRepo()),
            ),
            child: const LoginPage(),
          ),
        );
    }
  }
}
