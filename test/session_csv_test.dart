import 'package:app/models/scan_session.dart';
import 'package:app/models/sensor_data.dart';
import 'package:app/services/session_csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ScanSession session({String? gsrUnit, String? ppgUnit}) => ScanSession(
        id: 7,
        startTime: DateTime(2026, 10, 9, 14, 5, 3),
        emotion: 'Happy',
        gsrUnit: gsrUnit,
        ppgUnit: ppgUnit,
        sensorDataList: const [
          SensorData(
              timeStamp: 1000, accelX: 0.5, grs: 820.5, ppg: 1180.9, emg: -1),
          SensorData(timeStamp: 1007.8, grs: 821),
        ],
      );

  test('units go in the column names, one row per sample', () {
    expect(
      SessionCsv.build(session(gsrUnit: 'kOhms', ppgUnit: 'mV')),
      'timestamp_ms,accel_x,gsr_kOhms,ppg_mV,emg\n'
      '1000.0,0.5,820.5,1180.9,-1.0\n'
      '1007.8,,821.0,,\n',
    );
  });

  test('sessions saved without units get plain column names', () {
    expect(SessionCsv.header(session()),
        ['timestamp_ms', 'accel_x', 'gsr', 'ppg', 'emg']);
  });

  test('unit text that would break the CSV header is cleaned', () {
    expect(SessionCsv.header(session(gsrUnit: 'k Ohms, cal', ppgUnit: 'mV'))[2],
        'gsr_k_Ohms_cal');
  });

  test('file name has the session id and start time', () {
    expect(SessionCsv.fileName(session()), 'scan_7_20261009_140503.csv');
  });
}
