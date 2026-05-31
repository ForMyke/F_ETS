import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dmbpvqhftfbpcuqawvyi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtYnB2cWhmdGZicGN1cWF3dnlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxNzMwNjcsImV4cCI6MjA5NTc0OTA2N30.IAKOSOiOkC3sr9UpbOHFbpyXVBSvtVLEFq3eJSP_2A8',
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