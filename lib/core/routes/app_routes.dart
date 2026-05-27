import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/presentation/bloc/forgot_password_bloc.dart';
import '../../features/auth/presentation/bloc/login_bloc.dart';
import '../../features/auth/presentation/bloc/reset_password_bloc.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/shell/presentation/pages/public_shell_page.dart';
import '../../features/shell/presentation/pages/admin_shell_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String adminLogin = '/admin-login';
  static const String adminHome = '/admin';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static AuthRepositoryImpl _buildRepo() => AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(client: http.Client()),
      );

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _fadeRoute(const PublicShellPage());

      case adminHome:
        return _fadeRoute(const AdminShellPage());

      case adminLogin:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => LoginBloc(
              loginUseCase: LoginUseCase(_buildRepo()),
            ),
            child: const LoginPage(),
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

      default:
        return _fadeRoute(const PublicShellPage());
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
