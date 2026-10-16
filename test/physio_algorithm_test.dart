import 'dart:convert';
import 'dart:io';

import 'package:app/models/sensor_data.dart';
import 'package:app/services/physio_algorithm.dart';
import 'package:flutter_test/flutter_test.dart';

/// Expected values come from the Python reference implementation that was
/// evaluated on CASE, run on a real Shimmer3 recording
/// (test/fixtures/physio_algorithm_shimmer.json).
void main() {
  final fixture = jsonDecode(
    File('test/fixtures/physio_algorithm_shimmer.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final double fs = (fixture['sampling_rate'] as num).toDouble();

  List<SensorData> window(Map<String, dynamic> w) {
    final ppg = (w['ppg_mv'] as List).cast<num>();
    final gsr = (w['gsr_kohm'] as List).cast<num>();
    return [
      for (var i = 0; i < ppg.length; i++)
        SensorData(ppg: ppg[i].toDouble(), grs: gsr[i].toDouble()),
    ];
  }

  void expectMatchesReference(PhysioFeatures f, Map<String, dynamic> w) {
    final e = w['expected'] as Map<String, dynamic>;
    expect(f.heartRate, closeTo(e['heart_rate'] as num, 1e-6));
    expect(f.rmssd, closeTo(e['rmssd'] as num, 1e-6));
    expect(f.scrPerMinute, closeTo(e['scr_per_minute'] as num, 1e-9));
    expect(f.scrAmplitudePerMinute,
        closeTo(e['scr_amplitude_per_minute'] as num, 1e-9));
    expect(f.skinConductance, closeTo(e['skin_conductance'] as num, 1e-9));
  }

  final baselineWindow = fixture['baseline'] as Map<String, dynamic>;
  final measurementWindow = fixture['measurement'] as Map<String, dynamic>;

  test('features match the Python reference on real Shimmer data', () {
    expectMatchesReference(
      PhysioAlgorithm.extract(window(baselineWindow), samplingRate: fs)!,
      baselineWindow,
    );
    expectMatchesReference(
      PhysioAlgorithm.extract(window(measurementWindow), samplingRate: fs)!,
      measurementWindow,
    );
  });

  test('prediction with and without a resting baseline', () {
    final baseline =
        PhysioAlgorithm.extract(window(baselineWindow), samplingRate: fs)!;
    final now =
        PhysioAlgorithm.extract(window(measurementWindow), samplingRate: fs)!;

    final withBaseline = PhysioAlgorithm.predict(now, baseline);
    expect(withBaseline.arousalScore,
        closeTo(fixture['expected_score_with_baseline'] as num, 1e-6));
    expect(withBaseline.emotion, fixture['expected_emotion_with_baseline']);
    expect(withBaseline.usedBaseline, isTrue);

    final withoutBaseline = PhysioAlgorithm.predict(now, null);
    expect(withoutBaseline.arousalScore,
        closeTo(fixture['expected_score_without_baseline'] as num, 1e-6));
    expect(
        withoutBaseline.emotion, fixture['expected_emotion_without_baseline']);
    expect(withoutBaseline.usedBaseline, isFalse);
  });

  test('a calm window compared with itself reads as Relaxed', () {
    final calm =
        PhysioAlgorithm.extract(window(baselineWindow), samplingRate: fs)!;
    expect(PhysioAlgorithm.predict(calm, calm).emotion, 'Relaxed');
  });

  test('returns null when the window is too short', () {
    final short = window(baselineWindow).sublist(0, (fs * 5).round());
    expect(PhysioAlgorithm.extract(short, samplingRate: fs), isNull);
  });
}
