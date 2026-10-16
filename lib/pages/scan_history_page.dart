import 'package:app/data/data_source/sensor_local_data_source.dart';
import 'package:app/main.dart';
import 'package:app/models/scan_session.dart';
import 'package:app/pages/scan_detail_page.dart';
import 'package:app/theme/emotion_visuals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ScanHistoryPage> {
  final dataSource = SensorLocalDataSource(db: database);
  List<ScanSession> _scanSessions = [];

  @override
  void initState() {
    super.initState();
    _loadScanSessions();
  }

  void _loadScanSessions() async {
    final data = await dataSource.getScanSessions();
    setState(() {
      _scanSessions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Scan History')),
      body: _scanSessions.isEmpty
          ? _EmptyState(scheme: scheme)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _scanSessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final scanSession = _scanSessions[index];
                final v = emotionVisual(scanSession.emotion);
                final camera = scanSession.cameraEmotion;
                final cameraVisual = emotionVisual(camera);
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    isThreeLine: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: v.color.withValues(alpha: 0.16),
                      foregroundColor: v.color,
                      child: Icon(v.icon),
                    ),
                    title: Text(
                      v.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    // Title/avatar are the sensor result; the camera result
                    // sits under it. Scans saved before schema v2, or with
                    // no face found, have no camera emotion.
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              camera == null
                                  ? Icons.face_retouching_off
                                  : cameraVisual.icon,
                              size: 16,
                              color: camera == null
                                  ? scheme.onSurfaceVariant
                                  : cameraVisual.color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              camera == null
                                  ? 'Camera: not recorded'
                                  : 'Camera: ${cameraVisual.label}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dateFormat.format(scanSession.startTime)} · '
                          '${timeFormat.format(scanSession.startTime)}',
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      tooltip: 'Delete',
                      onPressed: () async {
                        await dataSource.deleteScanSession(scanSession.id);
                        _loadScanSessions();
                      },
                      icon: Icon(Icons.delete_outline, color: scheme.error),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ScanDetailPage(scanSession: scanSession),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_toggle_off,
                size: 64, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No scans yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Completed scans will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
