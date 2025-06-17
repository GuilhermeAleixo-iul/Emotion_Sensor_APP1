import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isConnected = false; // Tracks Bluetooth connection status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shimmer3 Connection"), // Screen title
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {}, // TODO: Add settings screen
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              size: 50,
              color: _isConnected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _isConnected ? "Connected" : "Disconnected", // Connection status text
              style: TextStyle(
                fontSize: 24,
                color: _isConnected ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isConnected = !_isConnected; // Simulate connection (replace later)
                });
              },
              child: Text(_isConnected ? "Disconnect" : "Connect to Sensor"), // Button text
            ),
          ],
        ),
      ),
    );
  }
}