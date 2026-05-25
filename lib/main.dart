import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);

  await Supabase.initialize(
    url: 'https://yzivskishncxptyiphls.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl6aXZza2lzaG5jeHB0eWlwaGxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5MjI1NDIsImV4cCI6MjA5MzQ5ODU0Mn0.LXyU2XrDg_9YWBVyEf-Zbjxr3dVuZCC4vF0tu31iHrI',
  );

  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Eco-Quest',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
