import 'dart:async';
import 'dart:math';

import 'package:app/models/sensor_chart_data.dart';
import 'package:app/models/sensor_data.dart';
import 'package:app/pages/scan_history_page.dart';
import 'package:app/pages/scan_page.dart';
import 'package:app/services/shimmer_service.dart';
import 'package:app/widgets/charts/accel_chart.dart';
import 'package:app/widgets/charts/emg_chart.dart';
import 'package:app/widgets/charts/grs_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isConnected = false; // Tracks Bluetooth connection status
  String connectionState = "Disconnected";
  double timeStamp = 0.0;
  double accelX = 0.0;
  bool isScanPageVisible = false;

  List<SensorData> _sensorDataList = []; // List to store sensor data
  double previousTimeStamp = 0.0;
  int maxDataPoint = 100; // Maximum number of data points to display

  static const EventChannel event_channel = EventChannel(
    'com.example.emotion_sensor/shimmer/events',
  );

  static const MethodChannel _channel = MethodChannel(
    'com.example.emotion_sensor/shimmer',
  );

  Future<void> _connectToShimmer() async {
    await ShimmerService.connect();
  }

  Future<void> _startStreaming() async {
    await _channel.invokeMethod('startStreaming');
  }

  Future<void> _stopStreaming() async {
    await _channel.invokeMethod('stopStreaming');
  }

  Future<void> _disconnectShimmer() async {
    await _channel.invokeMethod('disconnect');
  }

  @override
  void initState() {
    super.initState();
    listenConnectionStatus();
  }

  void listenConnectionStatus() {
    event_channel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final data = Map<String, dynamic>.from(event);
        if (data['type'] == 'connectionData') {
          setState(() {
            connectionState = data['State'] ?? 'Unknown';
          });
        } else if (data['type'] == 'sensorData') {
          final currentTimeStamp = data['timeStamp'] as double;
          if (currentTimeStamp > previousTimeStamp + 100.0) {
            final sensorData = SensorData(
              timeStamp: data['timeStamp'] as double?,
              accelX: data['accel'] as double?,
              grs: data['gsrConductance'] as double?,
              ppg: data['ppgHeartRate'] as double?,
              emg: data['emgMuscleActivity'] as double?,
            );
            setState(() {
              timeStamp = data['timeStamp'] as double;
              accelX = data['accel'] as double;
              _sensorDataList.add(sensorData);
              if (_sensorDataList.length > maxDataPoint) {
                _sensorDataList.removeAt(0);
              }
            });
            previousTimeStamp = sensorData.timeStamp!;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shimmer3 Connection"), // Screen title
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                        return ScanHistoryPage();
                      }));
            }, // TODO: Add settings screen
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /* Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SensorDataLinechart(sensorDataList: _sensorDataList),
                  ),
                ),*/
                Icon(
                  _isConnected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  size: 50,
                  color: _isConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  connectionState,
                  style: TextStyle(
                    fontSize: 24,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (!_isConnected) {
                      await _connectToShimmer(); // Conectar
                    } else {
                      await _disconnectShimmer(); // Desconectar
                    }
                  },
                  child: Text(
                    _isConnected ? "Disconnect" : "Connect to Sensor",
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      //_startStreaming();
                      /*setState(() {
                        isScanPageVisible = true;
                      });*/
                       Navigator.push(context, MaterialPageRoute(builder: (context){
                        return ScanPage();
                      }));
                    },

                    child: Text(
                      "SCAN",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _startStreaming();
                      },
                      child: const Text('Start Streaming'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _stopStreaming();
                      },
                      child: const Text('Stop Streaming'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(timeStamp.toString()),
                Text(accelX.toString()),
              ],
            ),
            Visibility(
              visible: isScanPageVisible,
              child: Column(
                children: [
                  Expanded(child: AccelerometerChart(sensorDataList: _sensorDataList)),
                  Expanded(child: EmgChart(sensorDataList: _sensorDataList)),
                  Expanded(child: GrsChart(sensorDataList: _sensorDataList)),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _stopStreaming();
                        setState(() {
                          isScanPageVisible = false;
                        });
                      },
                      child: Text(
                        "Stop Streaming",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
