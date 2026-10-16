import 'package:app/data/database/app_database.dart';
import 'package:app/models/scan_session.dart';
import 'package:app/models/sensor_data.dart';
import 'package:drift/drift.dart';

// Drift-backed persistence for scan sessions and their sensor samples.
class SensorLocalDataSource {
  final AppDatabase db;
  SensorLocalDataSource({required this.db});

  Future<bool> saveScanSession(
    List<SensorData> sensorDataList,
    String emotion, {
    String? cameraEmotion,
    String? gsrUnit,
    String? ppgUnit,
  }) async {
    try {
      await db.transaction(() async {
        final sessionId = await db.into(db.scanSessions).insert(
              ScanSessionsCompanion.insert(
                startTime: DateTime.now(),
                emotion: emotion,
                cameraEmotion: Value(cameraEmotion),
                gsrUnit: Value(gsrUnit),
                ppgUnit: Value(ppgUnit),
              ),
            );
        // Batched insert: one statement for the whole session's samples.
        await db.batch((batch) {
          batch.insertAll(
            db.sensorReadings,
            sensorDataList.map(
              (e) => SensorReadingsCompanion.insert(
                sessionId: sessionId,
                timeStamp: Value(e.timeStamp),
                accelX: Value(e.accelX),
                grs: Value(e.grs),
                ppg: Value(e.ppg),
                emg: Value(e.emg),
              ),
            ),
          );
        });
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ScanSession>> getScanSessions() async {
    try {
      final sessions = await db.select(db.scanSessions).get();
      final result = <ScanSession>[];
      for (final s in sessions) {
        final readings = await (db.select(db.sensorReadings)
              ..where((t) => t.sessionId.equals(s.id))
              ..orderBy([(t) => OrderingTerm(expression: t.timeStamp)]))
            .get();
        result.add(
          ScanSession(
            id: s.id,
            startTime: s.startTime,
            emotion: s.emotion,
            cameraEmotion: s.cameraEmotion,
            gsrUnit: s.gsrUnit,
            ppgUnit: s.ppgUnit,
            sensorDataList: readings
                .map(
                  (r) => SensorData(
                    timeStamp: r.timeStamp,
                    accelX: r.accelX,
                    grs: r.grs,
                    ppg: r.ppg,
                    emg: r.emg,
                  ),
                )
                .toList(),
          ),
        );
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteScanSession(int id) async {
    try {
      // Delete children then parent explicitly, so this holds regardless of
      // whether SQLite foreign-key enforcement is enabled.
      await db.transaction(() async {
        await (db.delete(db.sensorReadings)
              ..where((t) => t.sessionId.equals(id)))
            .go();
        await (db.delete(db.scanSessions)..where((t) => t.id.equals(id))).go();
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
