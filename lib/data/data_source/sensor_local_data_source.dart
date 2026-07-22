import 'package:app/data/collections/scan_session_collection.dart';
import 'package:app/data/collections/sensor_data_collection.dart';
import 'package:app/models/scan_session.dart';
import 'package:app/models/sensor_data.dart';
import 'package:isar_community/isar.dart';

class SensorLocalDataSource {
  final Isar isar;
  SensorLocalDataSource({required this.isar});

  Future<bool> saveScanSession(List<SensorData> sensorDataList, String emotion) async {
    final scanSession = ScanSessionCollection()
      ..startTime = DateTime.now()..emotion=emotion; //
    try {
      await isar.writeTxn(() async {
        final sessionId = await isar.scanSessionCollections.put(scanSession);
        final sensorDataCollectionList =
            sensorDataList.map((element) {
              final collection = element.toCollection();
              collection.scanSession.value = scanSession;
              return collection;
            }).toList();

        final ids = await isar.sensorDataCollections.putAll(
          sensorDataCollectionList,
        );
        /*debugPrint('Saved Ids $ids');
        for (final sensorData in sensorDataCollectionList) {
          //looping the list
          await sensorData.scanSession.save();
        }*/

        scanSession.sensorData.addAll(sensorDataCollectionList);
        await scanSession.sensorData.save();

      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ScanSession>> getScanSessions() async {
    try {
      final sessions = await isar.scanSessionCollections.where().findAll();
      //debugPrint(' Source Sessions ${sessions}');
      for(
        final session in sessions
      ){
        await session.sensorData.load();
      }
      return sessions.map((e) => e.toModel()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteScanSession(int id) async {
    try {
      await isar.writeTxn(() async {
        final sensorData =
            await isar.sensorDataCollections
                .filter()
                .scanSession((q) => q.idEqualTo(id))
                .findAll();
        final sensorDataIds = sensorData.map((element) => element.id).toList();
        if (sensorDataIds.isNotEmpty) {
          await isar.sensorDataCollections.deleteAll(sensorDataIds);
        }
        await isar.scanSessionCollections.delete(id);
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
