import 'package:app/models/sensor_data.dart';
import 'package:app/pages/camera_page.dart';
import 'package:app/pages/scan_history_page.dart';
import 'package:app/services/shimmer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String connectionState = "Disconnected";
  final List<SensorData> _sensorDataList = [];
  double previousTimeStamp = 0.0;
  int maxDataPoint = 100;

  static const EventChannel event_channel = EventChannel(
    'com.example.emotion_sensor/shimmer/events',
  );
  static const MethodChannel _channel = MethodChannel(
    'com.example.emotion_sensor/shimmer',
  );

  // Derived from the connection string the native side reports, replacing the
  // old `_isConnected` flag that was never assigned (so the icon stayed grey).
  bool get _connected {
    final s = connectionState.toLowerCase();
    if (s.contains('disconnect')) return false;
    return s.contains('connect') || s.contains('stream');
  }

  /// Asks for Bluetooth permission if needed, then opens the device picker.
  Future<void> _connectToShimmer() async {
    try {
      await ShimmerService.connect();
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Could not connect.')),
      );
    }
  }
  Future<void> _disconnectShimmer() async =>
      _channel.invokeMethod('disconnect');

  @override
  void initState() {
    super.initState();
    listenConnectionStatus();
  }

  void listenConnectionStatus() {
    event_channel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final data = Map<String, dynamic>.from(event);
        if (data['type'] == 'connectionData') {
          setState(() {
            connectionState = data['State'] ?? 'Unknown';
          });
        } else if (data['type'] == 'sensorData') {
          final currentTimeStamp = data['timeStamp'] as double;
          if (currentTimeStamp > previousTimeStamp + 100.0) {
            final sensorData = SensorData(
              timeStamp: data['timeStamp'] as double?,
              accelX: data['accel'] as double?,
              grs: data['gsrConductance'] as double?,
              ppg: data['ppgHeartRate'] as double?,
              emg: data['emgMuscleActivity'] as double?,
            );
            setState(() {
              _sensorDataList.add(sensorData);
              if (_sensorDataList.length > maxDataPoint) {
                _sensorDataList.removeAt(0);
              }
            });
            previousTimeStamp = sensorData.timeStamp!;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final connected = _connected;
    final statusColor = connected ? const Color(0xFF10B981) : scheme.outline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Sensor'),
        actions: [
          IconButton(
            tooltip: 'Scan history',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanHistoryPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor.withValues(alpha: 0.14),
                      ),
                      child: Icon(
                        connected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        size: 46,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Shimmer3 Sensor',
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      connectionState,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: connected ? statusColor : scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () async {
                  if (!connected) {
                    await _connectToShimmer();
                  } else {
                    await _disconnectShimmer();
                  }
                },
                icon: Icon(
                    connected ? Icons.link_off : Icons.bluetooth_searching),
                label: Text(connected ? 'Disconnect' : 'Connect to Sensor'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CameraPage()),
                ),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Start Scan'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
