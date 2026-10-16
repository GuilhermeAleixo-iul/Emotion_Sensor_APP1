import 'package:app/models/sensor_data.dart';

class ScanSession {
  final int id;
  final DateTime startTime;
  final List<SensorData> sensorDataList;
  final String emotion;
  /// Camera (face) emotion at the time of the scan; null if none was detected.
  final String? cameraEmotion;
  /// Units of the GSR and PPG values as reported by the Shimmer (e.g. "kOhms",
  /// "mV"); null for sessions saved before units were recorded.
  final String? gsrUnit;
  final String? ppgUnit;
  ScanSession({
    required this.startTime, required this.sensorDataList, required this.id, required this.emotion,
    this.cameraEmotion, this.gsrUnit, this.ppgUnit,
  });
}