import 'dart:convert';
import 'dart:io';

import 'package:app/models/sensor_data.dart';
import 'package:app/services/emotion_interpreter.dart';
import 'package:app/services/scan_features.dart';
import 'package:flutter_test/flutter_test.dart';

/// Expected values come from the Python code the model was trained with
/// (physio_algorithm/physio_scan.py, make_scan_fixture.py). The TFLite model
/// itself needs the native runtime, so the logistic regression is checked
/// through [ArousalModelParameters.logistic], which computes the same thing.
void main() {
  final fixture = jsonDecode(
    File('test/fixtures/scan_features_fixture.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final parameters = ArousalModelParameters.fromJson(
    jsonDecode(File(EmotionInterpreter.parametersAsset).readAsStringSync())
        as Map<String, dynamic>,
  );
  final shimmer = jsonDecode(
    File('test/fixtures/physio_algorithm_shimmer.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  List<double> doubles(dynamic v) =>
      [for (final x in v as List) (x as num).toDouble()];

  void expectFeatures(Map<String, double> got, Map<String, dynamic> expected) {
    for (final name in ScanFeatures.names) {
      final e = expected[name];
      if (e == null) {
        expect(got[name]!.isNaN, isTrue, reason: '$name should be missing');
      } else {
        final ev = (e as num).toDouble();
        expect(got[name], closeTo(ev, 1e-9 + 1e-9 * ev.abs()), reason: name);
      }
    }
  }

  test('bundled parameters: 12 known features, scaler and weights line up', () {
    expect(parameters.features, hasLength(12));
    expect(parameters.mean, hasLength(12));
    expect(parameters.scale, hasLength(12));
    expect(parameters.weights, hasLength(12));
    expect(parameters.strongThreshold, greaterThan(parameters.threshold));
  });

  test('features match Python on real Shimmer data at 128 Hz', () {
    for (final name in ['baseline', 'measurement']) {
      final w = shimmer[name] as Map<String, dynamic>;
      final gsrUs = [for (final k in doubles(w['gsr_kohm'])) 1000.0 / k];
      expectFeatures(
        ScanFeatures.compute(doubles(w['ppg_mv']), gsrUs, 128.0),
        (fixture['shimmer_128'][name]['expected']) as Map<String, dynamic>,
      );
    }
  });

  group('a real app scan at 51.2 Hz', () {
    final app = fixture['app_51'] as Map<String, dynamic>;
    final fs = (app['sampling_rate'] as num).toDouble();
    final gsr = doubles(app['gsr_kohm']);
    final ppg = doubles(app['ppg_mv']);
    final scan = [
      for (var i = 0; i < gsr.length; i++) SensorData(ppg: ppg[i], grs: gsr[i]),
    ];
    final expectedWindows = (app['windows'] as List).cast<Map<String, dynamic>>();

    test('windows: skip the settling period, then 60 s every 30 s', () {
      expect(parameters.windows(scan.length, fs), [
        for (final w in expectedWindows) (w['start'] as int, w['end'] as int),
      ]);
    });

    test('features and P(high arousal) per window match Python', () {
      final ps = <double>[];
      for (final w in expectedWindows) {
        final f = ScanFeatures.fromSamples(
            scan.sublist(w['start'] as int, w['end'] as int), fs);
        expectFeatures(f, w['features'] as Map<String, dynamic>);
        final p = parameters.logistic(parameters.standardize(parameters.inputs(f)));
        expect(p, closeTo((w['p_high'] as num).toDouble(), 1e-9));
        ps.add(p);
      }
      final mean = ps.reduce((a, b) => a + b) / ps.length;
      expect(mean, closeTo((app['mean_p_high'] as num).toDouble(), 1e-9));
    });
  });

  group('window rule', () {
    test('too short to score', () {
      expect(parameters.windows((29 * 51.2).round(), 51.2), isEmpty);
    });
    test('a 30 s scan is scored whole, with no settling skip', () {
      final n = (30 * 51.2).round();
      expect(parameters.windows(n, 51.2), [(0, n)]);
    });
    test('a 45 s scan keeps its last 30 s', () {
      final n = (45 * 128.0).round();
      expect(parameters.windows(n, 128.0), [(15 * 128, n)]);
    });
    test('a 120 s scan gives two 60 s windows after a 20 s settle', () {
      expect(parameters.windows(120 * 128, 128.0),
          [(20 * 128, 80 * 128), (50 * 128, 110 * 128)]);
    });
  });

  test('a missing feature is standardised to the training mean', () {
    final z = parameters.standardize(
        [for (var i = 0; i < 12; i++) i == 3 ? double.nan : parameters.mean[i]]);
    expect(z, everyElement(0.0));
  });
}
