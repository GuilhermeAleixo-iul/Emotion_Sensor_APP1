import 'package:app/data/collections/scan_session_collection.dart';
import 'package:app/data/collections/sensor_data_collection.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarDatabase {

  const IsarDatabase._();
  static Future<Isar> createIsarDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([ScanSessionCollectionSchema, SensorDataCollectionSchema], directory: dir.path);
  }

}