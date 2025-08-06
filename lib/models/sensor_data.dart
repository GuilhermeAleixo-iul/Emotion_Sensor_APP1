import 'package:app/data/collections/sensor_data_collection.dart';

class SensorData{
  
  final double? timeStamp;
  final double? accelX;
  final double? grs;
  final double? ppg;  
  final double? emg;

  const SensorData({this.timeStamp, this.accelX, this.grs, this.ppg, this.emg});
  SensorDataCollection toCollection() {
    return SensorDataCollection(timeStamp: timeStamp, accelX: accelX, grs: grs);
  }

}