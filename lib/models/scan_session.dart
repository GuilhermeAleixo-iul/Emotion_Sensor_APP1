import 'package:app/models/sensor_data.dart';

class ScanSession {
  final DateTime startTime;
  final List<SensorData> sensorDataList;
  ScanSession({
    required this.startTime, required this.sensorDataList
  });
}