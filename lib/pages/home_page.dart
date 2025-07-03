import 'package:app/models/sensor_data.dart';
import 'package:app/services/shimmer_service.dart';
import 'package:app/widgets/sensor_data_linechart.dart';
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
  List<SensorData> _sensorDataList = []; // List to store sensor data
  double previousTimeStamp = 0.0;
  int maxDataPoint = 30; // Maximum number of data points to display

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
    listenConectionStatus();
  }

  void listenConectionStatus() {
    event_channel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final data = Map<String, dynamic>.from(event);
        if (data['type'] == 'connectionData') {
          setState(() {
            connectionState = data['State'] ?? 'Unknown';
          });
        } else if (data['type'] == 'sensorData') {
          final sensorData = SensorData(
            timeStamp: data['timeStamp'] as double?,
            accelX: data['accel'] as double?,
            grs: data['gsrConductance'] as double?,
            ppg: data['ppgHeartRate'] as double?,
            emg: data['emgMuscleActivity'] as double?,
          );
          if (sensorData.timeStamp! > previousTimeStamp + 200.0) {
            setState(() {
              timeStamp = data['timeStamp'] as double;
            accelX = data['accel'] as double;
             _sensorDataList.add(sensorData) ;
             if(_sensorDataList.length > maxDataPoint){
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
            icon: const Icon(Icons.settings),
            onPressed: () {}, // TODO: Add settings screen
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Expanded(child: SensorDataLinechart(sensorDataList: _sensorDataList)),
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
              child: Text(_isConnected ? "Disconnect" : "Connect to Sensor"),
            ),
            const SizedBox(height: 30),
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
      ),
    );
  }
}
