import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const EtsApp());
}

class EtsApp extends StatelessWidget {
  const EtsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
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
      },
    );
  }
}