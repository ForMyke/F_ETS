import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/login_bloc.dart';
import '../../features/auth/presentation/bloc/register_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case register:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => RegisterBloc(
              registerUseCase: RegisterUseCase(
                AuthRepositoryImpl(
                  remoteDataSource: AuthRemoteDataSourceImpl(
                    client: http.Client(),
                  ),
                ),
              ),
            ),
            child: const RegisterPage(),
          ),
        );
      case login:
      default:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => LoginBloc(
              loginUseCase: LoginUseCase(
                AuthRepositoryImpl(
                  remoteDataSource: AuthRemoteDataSourceImpl(
                    client: http.Client(),
                  ),
                ),
              ),
            ),
            child: const LoginPage(),
          ),
        );
    }
  }
}
