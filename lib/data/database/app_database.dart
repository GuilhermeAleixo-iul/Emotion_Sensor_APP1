import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

// One scan session.
@DataClassName('ScanSessionRow')
class ScanSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startTime => dateTime()();
  TextColumn get emotion => text()();
  // Face model result from the camera page; null when no face was found.
  // Added in schema version 2.
  TextColumn get cameraEmotion => text().nullable()();
  // Units the Shimmer reported for the GSR and PPG values, e.g. "kOhms" and
  // "mV". Null for sessions saved before schema version 3.
  TextColumn get gsrUnit => text().nullable()();
  TextColumn get ppgUnit => text().nullable()();
}

// One sensor sample belonging to a session.
@DataClassName('SensorReadingRow')
class SensorReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(ScanSessions, #id, onDelete: KeyAction.cascade)();
  RealColumn get timeStamp => real().nullable()();
  RealColumn get accelX => real().nullable()();
  RealColumn get grs => real().nullable()();
  RealColumn get ppg => real().nullable()();
  RealColumn get emg => real().nullable()();
}

@DriftDatabase(tables: [ScanSessions, SensorReadings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(scanSessions, scanSessions.cameraEmotion);
          }
          if (from < 3) {
            await m.addColumn(scanSessions, scanSessions.gsrUnit);
            await m.addColumn(scanSessions, scanSessions.ppgUnit);
          }
        },
      );
}

// Opens the SQLite file in the app documents directory. LazyDatabase defers
// this until the first query.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/emotion_sensor.sqlite');
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    return NativeDatabase.createInBackground(file);
  });
}
