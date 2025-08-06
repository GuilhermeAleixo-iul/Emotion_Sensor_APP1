import 'package:app/data/database/isar_database.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'pages/home_page.dart'; // HomePage for Bluetooth connection

late Isar isar; // Late for initialization

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isar = await IsarDatabase.createIsarDatabase(); //it takes time to create the database, thats why we dont put before the class
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