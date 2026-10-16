import 'package:app/models/scan_session.dart';
import 'package:app/services/session_csv.dart';
import 'package:app/theme/emotion_visuals.dart';
import 'package:app/widgets/charts/sensor_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ScanDetailPage extends StatelessWidget {
  const ScanDetailPage({super.key, required this.scanSession});
  final ScanSession scanSession;

  Future<void> _export(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final location = await SessionCsv.saveToDownloads(scanSession);
      messenger.showSnackBar(SnackBar(content: Text('Saved to $location')));
    } on PlatformException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save the CSV: ${e.message}')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save the CSV: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final readings = scanSession.sensorDataList;

    double windowSize = 10.0;
    if (readings.length >= 2) {
      windowSize =
          (readings.last.timeStamp! - readings.first.timeStamp!) / 1000.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Detail'),
        actions: [
          IconButton(
            tooltip: 'Save CSV to Downloads',
            icon: const Icon(Icons.download),
            onPressed: readings.isEmpty ? null : () => _export(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary header: sensor and camera emotions + when + how many
          // samples.
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _EmotionResult(
                        label: 'Sensor',
                        icon: Icons.sensors,
                        emotion: scanSession.emotion,
                      ),
                    ),
                    Expanded(
                      child: _EmotionResult(
                        label: 'Camera',
                        icon: Icons.face_outlined,
                        emotion: scanSession.cameraEmotion,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  DateFormat('EEEE, MMM d · h:mm a')
                      .format(scanSession.startTime),
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  '${readings.length} samples',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: ChartCard(
                title: 'Accelerometer',
                color: SensorColors.accel,
                child: SensorLineChart(
                  data: readings,
                  selector: (d) => d.accelX,
                  color: SensorColors.accel,
                  windowSize: windowSize,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ChartCard(
                title: 'PPG · Heart Rate',
                color: SensorColors.ppg,
                child: SensorLineChart(
                  data: readings,
                  selector: (d) => d.ppg,
                  color: SensorColors.ppg,
                  windowSize: windowSize,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: ChartCard(
                title: 'GSR · Skin Response',
                color: SensorColors.gsr,
                child: SensorLineChart(
                  data: readings,
                  selector: (d) => d.grs,
                  color: SensorColors.gsr,
                  windowSize: windowSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One labelled result in the header, e.g. "Sensor" over an emotion chip.
class _EmotionResult extends StatelessWidget {
  const _EmotionResult({
    required this.label,
    required this.icon,
    required this.emotion,
  });

  final String label;
  final IconData icon;

  /// Null for scans saved without a camera result (no face, or before
  /// schema v2); shown as a grey "Not recorded" chip.
  final String? emotion;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: muted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        EmotionChip(emotion: emotion ?? 'Not recorded', large: true),
      ],
    );
  }
}
