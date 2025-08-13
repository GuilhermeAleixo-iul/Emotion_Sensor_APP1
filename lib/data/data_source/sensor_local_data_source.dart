
import 'package:app/data/collections/scan_session_collection.dart';
import 'package:app/data/collections/sensor_data_collection.dart';
import 'package:app/models/scan_session.dart';
import 'package:app/models/sensor_data.dart';
import 'package:isar/isar.dart';

class SensorLocalDataSource {

  final Isar isar;
  SensorLocalDataSource({
    required this.isar,
  });

  Future<bool> saveScanSession(List<SensorData> sensorDataList) async {
    final scanSession = ScanSessionCollection(
      
    );
    try{
      await isar.writeTxn(() async {
        final sessionId = await isar.scanSessionCollections.put(scanSession);
        final sensorDataCollectionList = sensorDataList.map((element){
          final collection = element.toCollection();
          collection.scanSession.value = scanSession;
          return collection;
        }).toList();
        
        await isar.sensorDataCollections.putAll(sensorDataCollectionList);
        for(final sensorData in sensorDataCollectionList){  //looping the list
          await sensorData.scanSession.save();
        }

      });
      return true;
    } catch(e) {
        return false;
    }
  }

  Future<List<ScanSession>> getScanSessions() async {
    try{
     final sessions = await isar.scanSessionCollections.where().findAll();
      return sessions.map((e) => e.toModel()).toList();
    } catch(e){
      return [];
    }
  }

}