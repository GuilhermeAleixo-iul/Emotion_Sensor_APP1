import 'package:app/data/data_source/sensor_local_data_source.dart';
import 'package:app/main.dart';
import 'package:app/models/sensor_data.dart';
import 'package:app/services/emotion_interpreter.dart';
import 'package:app/services/physio_algorithm.dart';
import 'package:app/services/scan_features.dart';
import 'package:app/theme/emotion_visuals.dart';
import 'package:app/widgets/charts/sensor_line_chart.dart';
import 'package:app/widgets/emotion_dialog.dart';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

/// How the sensor emotion is predicted: the TFLite arousal model
/// ([EmotionInterpreter], features from [ScanFeatures]), or the rule-based
/// [PhysioAlgorithm].
enum PredictionMethod { model, algorithm }

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, this.cameraEmotion});
  final String? cameraEmotion;

  @override
  State<ScanPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ScanPage> {
  List<SensorData> _sensorDataList = []; // List to store sensor data
  double previousTimeStamp = 0.0;
  int maxDataPoint = 100; // Maximum number of data points to display
  static const EventChannel event_channel = EventChannel(
    'com.example.emotion_sensor/shimmer/events',
  );
  static const MethodChannel _channel = MethodChannel(
    'com.example.emotion_sensor/shimmer',
  );

  StreamSubscription? _streamSubscription;
  final dataSource = SensorLocalDataSource(db: database);
  final emotionInterpreter = EmotionInterpreter();
  double? sampleRate = null;

  /// Units the Shimmer reports for GSR and PPG; saved with the session.
  String? _gsrUnit;
  String? _ppgUnit;
  String? _predictedEmotion = null;
  // The CUADS model beats the rule algorithm on Shimmer data (AUC 0.61 vs 0.50).
  PredictionMethod _method = PredictionMethod.model;

  /// Shows the "Set rest baseline" button. Off for now: the algorithm runs
  /// without a baseline until baselines are checked on CUADS.
  static const bool _baselineEnabled = false;

  /// Samples before this index were used as the algorithm's rest baseline.
  int _measureStart = 0;

  // Native sends -1.0 while the Shimmer hasn't reported its rate.
  double get _rate => (sampleRate ?? 0) > 0 ? sampleRate! : 128.0;

  @override
  void initState() {
    super.initState();
    startListening();
    emotionInterpreter.loadModelAndScalers().then(
      (d) => _showSnackBar('Model Loaded'),
    );
  }

  void startListening() async {
    await _startStreaming();
    listenSensorData();
  }

  @override
  void dispose() {
    super.dispose();
    _stopStreaming();
    _streamSubscription?.cancel();
    emotionInterpreter.dispose();
  }

  Future<void> _stopStreaming() async {
    await _channel.invokeMethod('stopStreaming');
  }

  Future<void> _startStreaming() async {
    await _channel.invokeMethod('startStreaming');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
    );
  }

  /// Shortest scan the model scores; it works best from 80 s (a 20 s settle
  /// plus one full 60 s window).
  double get _modelMinSeconds =>
      emotionInterpreter.parameters?.minSeconds ?? 30;

  /// Null when there is too little data or the model isn't ready; a snackbar
  /// says why.
  String? _getShimmerEmotion() {
    if (_method == PredictionMethod.algorithm) return _getAlgorithmEmotion();
    return _getModelEmotion();
  }

  String? _getModelEmotion() {
    if (!emotionInterpreter.isLoaded) {
      _showSnackBar('The model is still loading. Try again in a moment.');
      return null;
    }
    final prediction = emotionInterpreter.predictScan(_sensorDataList, _rate);
    if (prediction == null) {
      _showSnackBar('Record at least ${_modelMinSeconds.round()} s first.');
      return null;
    }
    debugPrint(
      'Model: P(high arousal) ${prediction.pHigh.toStringAsFixed(3)} from '
      '${prediction.windowProbabilities.map((p) => p.toStringAsFixed(3))} '
      'over ${prediction.secondsScored.round()} s at ${_rate.toStringAsFixed(1)} Hz',
    );
    return emotionInterpreter.emotionFor(prediction.pHigh);
  }

  String? _getAlgorithmEmotion() {
    final features = PhysioAlgorithm.extract(
      _sensorDataList.sublist(_measureStart),
      samplingRate: _rate,
    );
    if (features == null) {
      _showSnackBar(
        'Record at least ${PhysioAlgorithm.minSeconds.round()} s of GSR first.',
      );
      return null;
    }
    final result = PhysioAlgorithm.predict(features, PhysioBaseline.current);
    debugPrint(
      'Algorithm: $features, score ${result.arousalScore.toStringAsFixed(2)}, '
      'baseline ${result.usedBaseline}',
    );
    return result.emotion;
  }

  /// Uses everything recorded since the last baseline as the resting
  /// baseline, then measures from here on.
  void _setRestBaseline() {
    final features = PhysioAlgorithm.extract(
      _sensorDataList.sublist(_measureStart),
      samplingRate: _rate,
    );
    if (features == null || features.seconds < 30) {
      _showSnackBar('Sit still for at least 30 s (60 s is better) first.');
      return;
    }
    setState(() {
      PhysioBaseline.current = features;
      _measureStart = _sensorDataList.length;
      _predictedEmotion = null;
    });
    _showSnackBar('Rest baseline saved. Measuring from now.');
  }

  String _methodDescription() {
    if (_method == PredictionMethod.model) {
      return 'Runs the arousal model trained on CUADS (same Shimmer sensor) on '
          'heart-rate and sweat patterns within the scan. Keep the hand still; '
          '80 s or more gives the best result.';
    }
    final base = PhysioBaseline.current;
    if (base == null) {
      return 'Compares heart rate and sweat responses with average resting '
          'values.';
    }
    final hr = base.heartRate == null
        ? ''
        : 'HR ${base.heartRate!.round()} bpm, ';
    return 'Compares with your rest baseline '
        '(${hr}SCL ${base.skinConductance.toStringAsFixed(2)} µS).';
  }

  /// Seconds of data the selected method will use.
  double _recordedSeconds() {
    final samples = _method == PredictionMethod.algorithm
        ? _sensorDataList.length - _measureStart
        : _sensorDataList.length;
    return samples / _rate;
  }

  void listenSensorData() {
    _streamSubscription = event_channel.receiveBroadcastStream().listen((
      event,
    ) {
      if (event is Map) {
        final data = Map<String, dynamic>.from(event);
        if (data['type'] == 'connectionData') {
          /*setState(() {
            connectionState = data['State'] ?? 'Unknown';
          });*/
        } else if (data['type'] == 'sensorData') {
          // Tolerate int or double (mock data often sends an int, or omits it).
          sampleRate = (data['sampleRate'] as num?)?.toDouble();
          _gsrUnit = data['gsrUnit'] as String? ?? _gsrUnit;
          _ppgUnit = data['ppgUnit'] as String? ?? _ppgUnit;
          final currentTimeStamp = data['timeStamp'] as double;
          final sensorData = SensorData(
            timeStamp: data['timeStamp'] as double?,
            accelX: data['accel'] as double?,
            grs: data['gsrConductance'] as double?,
            ppg: data['ppgHeartRate'] as double?,
            emg: data['emgMuscleActivity'] as double?,
          );
          setState(() {
            // timeStamp = data['timeStamp'] as double;
            // accelX = data['accel'] as double;
            _sensorDataList.add(sensorData);
          });
          previousTimeStamp = sensorData.timeStamp!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double elapseTime = 10.0;
    if (_sensorDataList.length >= 2) {
      elapseTime =
          _sensorDataList.last.timeStamp! - _sensorDataList.first.timeStamp!;
      elapseTime = elapseTime / 1000.0;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Scan')),
      body: Column(
        children: [
          // Accelerometer chart removed for now: no prediction method uses it.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: ChartCard(
                title: 'PPG · Heart Rate',
                color: SensorColors.ppg,
                child: SensorLineChart(
                  data: _sensorDataList,
                  selector: (d) => d.ppg,
                  color: SensorColors.ppg,
                  windowSize: elapseTime,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: ChartCard(
                title: 'GSR · Skin Response',
                color: SensorColors.gsr,
                child: SensorLineChart(
                  data: _sensorDataList,
                  selector: (d) => d.grs,
                  color: SensorColors.gsr,
                  windowSize: elapseTime,
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_predictedEmotion != null) ...[
                    Center(
                      child: EmotionChip(emotion: _predictedEmotion, large: true),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SegmentedButton<PredictionMethod>(
                    expandedInsets: EdgeInsets.zero,
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: PredictionMethod.model,
                        icon: Icon(Icons.memory),
                        label: Text('AI model'),
                      ),
                      ButtonSegment(
                        value: PredictionMethod.algorithm,
                        icon: Icon(Icons.rule),
                        label: Text('Algorithm'),
                      ),
                    ],
                    selected: {_method},
                    onSelectionChanged: (selection) => setState(() {
                      _method = selection.first;
                      _predictedEmotion = null;
                    }),
                  ),
                  const SizedBox(height: 10),
                  _MethodInfo(
                    description: _methodDescription(),
                    seconds: _recordedSeconds(),
                    minSeconds: _method == PredictionMethod.algorithm
                        ? PhysioAlgorithm.minSeconds
                        : _modelMinSeconds,
                  ),
                  if (_baselineEnabled && _method == PredictionMethod.algorithm)
                    TextButton.icon(
                      onPressed: _setRestBaseline,
                      icon: const Icon(Icons.self_improvement),
                      label: const Text('Set rest baseline'),
                    ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () async {
                      // Guard: with no samples, feature extraction yields an
                      // empty vector and the interpreter would crash on it.
                      if (_sensorDataList.isEmpty) {
                        _stopStreaming();
                        _showSnackBar('No sensor data captured yet.');
                        return;
                      }
                      // Predict before stopping, so a too-short algorithm
                      // window leaves the stream running.
                      final emotion = _getShimmerEmotion();
                      if (emotion == null) return;
                      _stopStreaming();
                      setState(() {
                        _predictedEmotion = emotion;
                      });
                      dataSource.saveScanSession(
                        _sensorDataList,
                        emotion,
                        cameraEmotion: widget.cameraEmotion,
                        gsrUnit: _gsrUnit,
                        ppgUnit: _ppgUnit,
                      );
                    },
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Stop Streaming'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      if (_sensorDataList.isEmpty) {
                        _showSnackBar('No sensor data captured yet.');
                        return;
                      }
                      final emotion = _predictedEmotion ?? _getShimmerEmotion();
                      if (emotion == null) return;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return EmotionDialog(
                            cameraEmotion: widget.cameraEmotion,
                            sensorEmotion: emotion,
                            onClosed: () => Navigator.pop(context),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.psychology_outlined),
                    label: const Text('Get Emotion'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// How the selected method predicts, and whether enough data is recorded.
class _MethodInfo extends StatelessWidget {
  const _MethodInfo({
    required this.description,
    required this.seconds,
    required this.minSeconds,
  });

  final String description;
  final double seconds;
  final double minSeconds;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.bodySmall;
    final ready = seconds > 0 && seconds >= minSeconds;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  description,
                  style: small?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                ready ? Icons.check_circle : Icons.timer_outlined,
                size: 18,
                color: ready ? const Color(0xFF10B981) : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                ready || minSeconds <= 0
                    ? '${seconds.round()} s recorded'
                    : '${seconds.round()} s recorded · needs '
                        '${minSeconds.round()} s',
                style: small?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
