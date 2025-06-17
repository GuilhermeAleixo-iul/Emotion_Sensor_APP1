import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // HomePage for Bluetooth connection

void main() {
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