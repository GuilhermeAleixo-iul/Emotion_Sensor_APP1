import 'dart:io';

import 'package:app/models/scan_session.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Exports a saved scan session's raw sensor samples as CSV.
///
/// Values are written as stored. The GSR and PPG column names carry the units
/// the Shimmer reported for the session (e.g. `gsr_kOhms`, `ppg_mV`); sessions
/// saved before units were recorded get plain `gsr` / `ppg`. A channel the
/// Shimmer did not send is -1. A sample with no value is left empty.
class SessionCsv {
  static const _channel = MethodChannel('com.example.emotion_sensor/files');

  static List<String> header(ScanSession session) => [
        'timestamp_ms',
        'accel_x',
        _withUnit('gsr', session.gsrUnit),
        _withUnit('ppg', session.ppgUnit),
        'emg',
      ];

  static String build(ScanSession session) {
    final buffer = StringBuffer()..writeln(header(session).join(','));
    for (final d in session.sensorDataList) {
      buffer.writeln(
        [d.timeStamp, d.accelX, d.grs, d.ppg, d.emg]
            .map((v) => v?.toString() ?? '')
            .join(','),
      );
    }
    return buffer.toString();
  }

  static String fileName(ScanSession session) =>
      'scan_${session.id}_'
      '${DateFormat('yyyyMMdd_HHmmss').format(session.startTime)}.csv';

  /// Saves the CSV to the phone's Download/EmotionSensor folder and returns
  static Future<String> saveToDownloads(ScanSession session) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Saving to Downloads is only available on Android');
    }
    final location = await _channel.invokeMethod<String>('saveToDownloads', {
      'fileName': fileName(session),
      'content': build(session),
      'mimeType': 'text/csv',
    });
    return location!;
  }

  /// "gsr" + "kOhms" -> "gsr_kOhms". Characters that would need CSV quoting
  /// (or read badly as a column name) become underscores.
  static String _withUnit(String name, String? unit) {
    final u = unit?.trim() ?? '';
    if (u.isEmpty) return name;
    return '${name}_${u.replaceAll(RegExp(r'[^A-Za-z0-9.%/]+'), '_')}';
  }
}
