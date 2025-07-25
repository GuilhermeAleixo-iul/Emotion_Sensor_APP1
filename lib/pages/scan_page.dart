import 'package:app/models/sensor_chart_data.dart';
import 'package:app/models/sensor_data.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:app/models/sensor_data.dart';
import 'package:app/services/shimmer_service.dart';
import 'package:app/widgets/sensor_data_linechart.dart';
import 'package:flutter/services.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ScanPage> {
  List<SensorData> _sensorDataList = []; // List to store sensor data
  double previousTimeStamp = 0.0;
  int maxDataPoint = 100; // Maximum number of data points to display
  static const EventChannel event_channel = EventChannel(
    'com.example.emotion_sensor/shimmer/events',
  );
static const MethodChannel _channel = MethodChannel(
    'com.example.emotion_sensor/shimmer',
  );

  @override
  void initState() {
    super.initState();
    listenConnectionStatus();
  }

  @override
  void dispose() {
    super.dispose();
    _stopStreaming();

  }


 Future<void> _stopStreaming() async {
    await _channel.invokeMethod('stopStreaming');
  }


  void listenConnectionStatus() {
    event_channel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final data = Map<String, dynamic>.from(event);
        if (data['type'] == 'connectionData') {
          /*setState(() {
            connectionState = data['State'] ?? 'Unknown';
          });*/
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
              // timeStamp = data['timeStamp'] as double;
              // accelX = data['accel'] as double;
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
      appBar: AppBar(title: Text('Scan Page', style: TextStyle(color: Colors.black12),)),
      body: Column(
        children: [
          SensorDataLinechart(
            sensorDataList:
                _sensorDataList.map((e) {
                  return SensorChartData(
                    timeStamp: e.timeStamp ?? 0.0,
                    data: e.accelX ?? 0.0,
                    title: "Acell",
                  );
                }).toList(),
          ),
          SensorDataLinechart(
            sensorDataList:
                _sensorDataList.map((e) {
                  return SensorChartData(
                    timeStamp: e.timeStamp ?? 0.0,
                    data: e.ppg ?? 0.0,
                    title: "PPG",
                  );
                }).toList(),
          ),
          SensorDataLinechart(
            sensorDataList:
                _sensorDataList.map((e) {
                  return SensorChartData(
                    timeStamp: e.timeStamp ?? 0.0,
                    data: e.emg ?? 0.0,
                    title: "EMG",
                  );
                }).toList(),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _stopStreaming();
              },
              child: Text(
                "Stop Streaming",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ),
        ],
      ),
    ); //empty widget
  }
}
