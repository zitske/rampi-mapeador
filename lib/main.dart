import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rampi_mapeador/Controller/navigation.dart';
import 'package:rampi_mapeador/View/main_view.dart';
import 'package:rampi_mapeador/View/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(Controller());

  await Supabase.initialize(
    url: 'https://zitske-group-rampi-supabase.o0p0en.easypanel.host',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q',
  );

  await [
    Permission.location,
    Permission.camera,
  ].request();

  runApp(GetMaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rampi - Democratizando as ruas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0191E2)),
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const MyHomePage(title: 'Rampi'),
      },
      initialRoute: '/',
    );
  }
}
