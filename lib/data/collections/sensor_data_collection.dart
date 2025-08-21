import 'package:app/data/collections/scan_session_collection.dart';
import 'package:app/models/sensor_data.dart';
import 'package:isar/isar.dart';

part 'sensor_data_collection.g.dart';

@collection
class SensorDataCollection {
  Id id = Isar.autoIncrement;
  @Index()
  final double? timeStamp;
  final double? accelX;
  final double? grs;
  final double? ppg;
  final scanSession = IsarLink<ScanSessionCollection>(); 

  SensorDataCollection({this.timeStamp, this.accelX, this.grs, this.ppg}); 
  SensorData toModel(){
    return SensorData(timeStamp: timeStamp, accelX: accelX, grs: grs, ppg: ppg);
  }
  @override
  String toString() {
    return 'timeStamp: $timeStamp, accelX $accelX, grs: $grs, ppg: $ppg';
  }
  }
