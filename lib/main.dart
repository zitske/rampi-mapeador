import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rampi_mapeador/Controller/navigation.dart';
import 'package:rampi_mapeador/View/login_view.dart';
import 'package:rampi_mapeador/View/main_view.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Controller c = Get.put(Controller());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      title: 'Rampi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? LoginScreen()
          : const MyHomePage(title: 'Mapeador de Rampas'),
    );
  }
}
