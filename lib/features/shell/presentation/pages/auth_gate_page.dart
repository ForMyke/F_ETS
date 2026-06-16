import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:etsAndroid/features/alumno/data/datasources/alumno_remote_datasource.dart';
import 'package:etsAndroid/features/alumno/presentation/pages/alumno_shell_page.dart';
import 'package:etsAndroid/features/jefe/data/datasources/jefe_remote_datasource.dart';
import 'package:etsAndroid/features/jefe/presentation/pages/jefe_shell_page.dart';
import 'package:etsAndroid/features/shell/presentation/pages/admin_shell_page.dart';
import 'package:etsAndroid/features/shell/presentation/pages/public_shell_page.dart';

/// Restaura la sesión activa (si existe) al iniciar/recargar la app y
/// navega directamente al shell correspondiente, en vez de mandar siempre
/// al usuario a la pantalla pública.
class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  Future<Widget> _resolverDestino() async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    if (session == null) return const PublicShellPage();

    final perfilAlumno =
        await AlumnoRemoteDataSourceImpl(client: client).getPerfilActual();
    if (perfilAlumno != null) return AlumnoShellPage(perfil: perfilAlumno);

    final perfilJefe =
        await JefeRemoteDataSourceImpl(client: client).getPerfilActual();
    if (perfilJefe != null) return JefeShellPage(perfil: perfilJefe);

    // Hay sesión pero no corresponde a alumno ni a jefe: se asume admin.
    return const AdminShellPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _resolverDestino(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data ?? const PublicShellPage();
      },
    );
  }
}
