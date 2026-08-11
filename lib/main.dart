import 'package:app/data/database/app_database.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // HomePage for Bluetooth connection
import 'package:camera/camera.dart';
late List<CameraDescription> cameras;
late AppDatabase database; // Drift database, shared app-wide

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  // Drift opens lazily on first query, so this no longer blocks startup the
  // way Isar.open did.
  database = AppDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emotion Sensor App', // App name (visible to users)
      theme: ThemeData(
        primarySwatch: Colors.blue, // Primary color
      ),
      home: const HomePage(), // Main screen
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}