import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qztkhyttuumtfhywamdp.supabase.co',
    anonKey: 'sb_publishable_AN8bxmkNGmX63Gtmd09U4w_RTx4gj8M',
  );

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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
