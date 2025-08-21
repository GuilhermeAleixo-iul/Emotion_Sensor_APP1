import 'package:app/data/collections/sensor_data_collection.dart';
import 'package:app/models/scan_session.dart';
import 'package:app/models/sensor_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';

part 'scan_session_collection.g.dart';

@collection
class ScanSessionCollection {

  Id id = Isar.autoIncrement;
  DateTime startTime = DateTime.now();
  final sensorData = IsarLinks<SensorDataCollection>();
  ScanSessionCollection();
  ScanSession toModel(){
    return ScanSession(
      id: id,
      startTime: startTime, sensorDataList: sensorData.map((
        collection
      ){
        return collection.toModel();
      }).toList() 
    );
  } 
  @override
  String toString() {
    return 'Sensor Data ${sensorData.toList()}';
  }

}