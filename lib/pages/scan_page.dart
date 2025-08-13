import 'package:app/data/data_source/sensor_local_data_source.dart';
import 'package:app/main.dart';
import 'package:app/models/sensor_chart_data.dart';
import 'package:app/models/sensor_data.dart';
import 'package:app/widgets/charts/emg_chart.dart';
import 'package:app/widgets/charts/grs_chart.dart';
import 'package:app/widgets/charts/accel_chart.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:app/models/sensor_data.dart';
import 'package:app/services/shimmer_service.dart';
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

  StreamSubscription? _streamSubscription;
  final dataSource = SensorLocalDataSource(isar: isar);

  @override
  void initState() {
    super.initState();
    startListening();
  }

  void startListening() async{
    await _startStreaming();
    listenSensorData();
  }

  @override
  void dispose() {
    super.dispose();
    _stopStreaming();
    _streamSubscription?.cancel();

  }


 Future<void> _stopStreaming() async {
    await _channel.invokeMethod('stopStreaming');
  }

 Future<void> _startStreaming() async {
    await _channel.invokeMethod('startStreaming');
  }

  void listenSensorData() {
     _streamSubscription = event_channel.receiveBroadcastStream().listen((event) {
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
            });
            previousTimeStamp = sensorData.timeStamp!;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double elapseTime = 10.0;
    if(_sensorDataList.length >= 2) {
      elapseTime = _sensorDataList.last.timeStamp! - _sensorDataList.first.timeStamp!;
      elapseTime = elapseTime / 1000.0;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Scan Page', style: TextStyle(color: Colors.black12),)),
      body: Column(
        children: [
          Expanded(
            child: AccelerometerChart(
              sensorDataList: _sensorDataList,
              windowSize: elapseTime,
            ),
          ),
          Expanded(
            child: EmgChart(
              sensorDataList: _sensorDataList,
              windowSize: elapseTime,   
            ),
          ),
          Expanded(
            child: GrsChart(
              sensorDataList: _sensorDataList,
              windowSize: elapseTime,    
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                _stopStreaming();
                dataSource.saveScanSession(_sensorDataList);
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
