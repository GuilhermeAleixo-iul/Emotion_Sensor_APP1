import 'dart:convert';
import 'dart:math' as math;

import 'package:app/models/sensor_data.dart';
import 'package:app/services/scan_features.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// No-baseline arousal model trained on CUADS, which was recorded with the
/// same Shimmer3 GSR+ as the app (physio_algorithm/train_consensus_arousal.py).
///
/// Logistic regression on 12 features from the scan itself ([ScanFeatures]).
/// It predicts whether the scan looks like the body's response to something
/// people generally find arousing. Nested cross-validation on CUADS, for
/// people the model never saw: AUC 0.61 (0.57-0.65), balanced accuracy 0.58;
/// for new people watching new clips, AUC 0.56-0.58. It has no valence, so
/// [emotionFor] only spreads arousal over the app's labels.
class EmotionInterpreter {
  static const modelAsset = 'assets/arousal_model.tflite';
  static const parametersAsset = 'assets/arousal_parameters.json';

  Interpreter? _interpreter;
  ArousalModelParameters? _parameters;

  bool get isLoaded => _interpreter != null && _parameters != null;
  ArousalModelParameters? get parameters => _parameters;

  Future<void> loadModelAndScalers() async {
    _interpreter = await Interpreter.fromAsset(modelAsset);
    _parameters = ArousalModelParameters.fromJson(
      json.decode(await rootBundle.loadString(parametersAsset))
          as Map<String, dynamic>,
    );
  }

  /// Scores [scan] recorded at [fs] Hz: P(high arousal) per window and their
  /// mean. Null before the model has loaded or when the scan is too short.
  ScanPrediction? predictScan(List<SensorData> scan, double fs) {
    final interpreter = _interpreter;
    final parameters = _parameters;
    if (interpreter == null || parameters == null) return null;
    final windows = parameters.windows(scan.length, fs);
    if (windows.isEmpty) return null;
    final probabilities = <double>[];
    for (final (start, end) in windows) {
      final features = ScanFeatures.fromSamples(scan.sublist(start, end), fs);
      final output = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run([parameters.standardize(parameters.inputs(features))], output);
      probabilities.add((output[0][0] as num).toDouble());
    }
    return ScanPrediction(
      pHigh: probabilities.reduce((a, b) => a + b) / probabilities.length,
      windowProbabilities: probabilities,
      secondsScored: (windows.last.$2 - windows.first.$1) / fs,
    );
  }

  /// The app's labels for P(high arousal): strongly aroused reads as 'Angry'
  /// (fear/stress in practice), aroused as 'Happy', calm as 'Relaxed'. The
  /// model has no valence, so 'Sad' is never returned.
  String emotionFor(double pHighArousal) {
    final parameters = _parameters!;
    if (pHighArousal > parameters.strongThreshold) return 'Angry';
    if (pHighArousal > parameters.threshold) return 'Happy';
    return 'Relaxed';
  }

  void dispose() {
    _interpreter?.close();
  }
}

class ScanPrediction {
  const ScanPrediction({
    required this.pHigh,
    required this.windowProbabilities,
    required this.secondsScored,
  });

  /// Mean P(high arousal) over the scan's windows.
  final double pHigh;
  final List<double> windowProbabilities;
  final double secondsScored;
}

/// Contents of `arousal_parameters.json`.
class ArousalModelParameters {
  ArousalModelParameters.fromJson(Map<String, dynamic> json)
      : features = List<String>.from(json['features'] as List),
        mean = _doubles(json['feature_scaler']['mean']),
        scale = _doubles(json['feature_scaler']['scale']),
        weights = _doubles(json['weights']),
        intercept = (json['intercept'] as num).toDouble(),
        threshold = (json['threshold'] as num).toDouble(),
        strongThreshold = (json['strong_threshold'] as num).toDouble(),
        windowSeconds = (json['scan']['window_seconds'] as num).toDouble(),
        hopSeconds = (json['scan']['hop_seconds'] as num).toDouble(),
        settleSeconds = (json['scan']['settle_seconds'] as num).toDouble(),
        minSeconds = (json['scan']['min_seconds'] as num).toDouble() {
    final unknown = features.where((f) => !ScanFeatures.names.contains(f));
    if (unknown.isNotEmpty) {
      throw FormatException('The model needs features the app lacks: $unknown');
    }
  }

  final List<String> features;
  final List<double> mean;
  final List<double> scale;
  final List<double> weights;
  final double intercept;
  final double threshold;
  final double strongThreshold;
  final double windowSeconds;
  final double hopSeconds;

  /// The Shimmer's start-up transient (first GSR sample, saturated PPG).
  final double settleSeconds;
  final double minSeconds;

  /// Model inputs in [features] order; NaN where a feature couldn't be computed.
  List<double> inputs(Map<String, double> f) =>
      [for (final name in features) f[name] ?? double.nan];

  /// Standardised inputs; a missing (NaN) feature becomes 0, the CUADS mean.
  List<double> standardize(List<double> raw) => [
        for (var i = 0; i < raw.length; i++)
          raw[i].isNaN ? 0.0 : (raw[i] - mean[i]) / scale[i],
      ];

  /// The same logistic regression the TFLite model computes. Used by tests.
  double logistic(List<double> z) {
    var s = intercept;
    for (var i = 0; i < z.length; i++) {
      s += weights[i] * z[i];
    }
    return 1 / (1 + math.exp(-s));
  }

  /// Sample ranges the model scores in a scan of [n] samples at [fs] Hz: skip
  /// up to [settleSeconds] while keeping at least [minSeconds], then windows of
  /// [windowSeconds] every [hopSeconds]; a shorter remainder is one window.
  List<(int, int)> windows(int n, double fs) {
    final w = (windowSeconds * fs).round();
    final h = (hopSeconds * fs).round();
    final settle = (settleSeconds * fs).round();
    final minimum = (minSeconds * fs).round();
    if (n < minimum) return const [];
    final start = math.min(settle, n - minimum);
    if (n - start < w) return [(start, n)];
    return [for (var s = start; s + w <= n; s += h) (s, s + w)];
  }

  static List<double> _doubles(dynamic v) =>
      [for (final x in v as List) (x as num).toDouble()];
}
