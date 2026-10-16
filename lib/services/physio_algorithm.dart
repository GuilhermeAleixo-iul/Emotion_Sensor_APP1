import 'dart:math' as math;

import 'package:app/models/sensor_data.dart';
import 'package:app/services/biquad.dart';

/// Rule-based alternative to the TFLite model.
///
/// No trained model: arousal is scored from changes in skin conductance level,
/// skin conductance responses (SCRs) and heart rate relative to the wearer's
/// own resting baseline. Weights and thresholds were tuned on CASE subjects
/// 1-15 and checked once on subjects 16-30, using a rest period right before
/// each clip as the baseline: arousal 0.65, valence 0.57, quadrant 0.37
/// accuracy, against 0.56 / 0.54 / 0.29 for always guessing the most common
/// answer.
///
/// Every feature is in physical units (bpm, ms, µS, responses/min), so results
/// do not depend on the Shimmer sampling rate as long as it is passed in.
class PhysioAlgorithm {
  /// Shortest window that gives a usable SCR rate and heart rate.
  static const double minSeconds = 20;

  /// Rise in conductance (µS) that counts as a skin conductance response.
  static const double _minScrAmplitude = 0.03;

  // CASE medians, used only when no resting baseline has been taken.
  static const double _populationHeartRate = 72.0;
  static const double _populationScrPerMinute = 2.0;

  static const double _arousedCut = 0.0;
  static const double _stronglyArousedCut = 1.5;

  /// Features for [window], or null when it holds under [minSeconds] of GSR.
  static PhysioFeatures? extract(
    List<SensorData> window, {
    required double samplingRate,
  }) {
    final ppg = <double>[];
    final gsr = <double>[];
    for (final d in window) {
      // Native code sends -1.0 when a channel is missing.
      if (d.ppg != null && d.ppg! > 0) ppg.add(d.ppg!);
      // The stream carries GSR as resistance in kΩ (GSR_RESISTANCE in
      // MainActivity.kt, and the mock data). The rules expect µS.
      if (d.grs != null && d.grs! > 0) gsr.add(1000.0 / d.grs!);
    }
    if (gsr.length < minSeconds * samplingRate) return null;

    final beats = _heartRate(ppg, samplingRate);
    final scr = _skinConductance(gsr, samplingRate);
    return PhysioFeatures(
      heartRate: beats.hr,
      rmssd: beats.rmssd,
      scrPerMinute: scr.perMinute,
      scrAmplitudePerMinute: scr.amplitudePerMinute,
      skinConductance: scr.level,
      seconds: gsr.length / samplingRate,
    );
  }

  /// Arousal score: above 0 is aroused, above 1.5 is strongly aroused.
  static double arousalScore(PhysioFeatures now, PhysioFeatures? baseline) {
    double c(double v) => v.clamp(-2.0, 2.0);
    if (baseline == null) {
      var score = c((now.scrPerMinute - _populationScrPerMinute) / 3);
      if (now.heartRate != null) {
        score += 0.5 * c((now.heartRate! - _populationHeartRate) / 5);
      }
      return score;
    }
    var score = 0.5 *
            c(math.log(now.skinConductance / baseline.skinConductance) / 0.10) +
        c((now.scrPerMinute - baseline.scrPerMinute) / 3);
    if (now.heartRate != null && baseline.heartRate != null) {
      score += 0.5 * c((now.heartRate! - baseline.heartRate!) / 5);
    }
    return score;
  }

  /// Maps the arousal score onto the app's quadrant labels.
  static AlgorithmResult predict(PhysioFeatures now, PhysioFeatures? baseline) {
    final score = arousalScore(now, baseline);
    final String emotion;
    if (score > _stronglyArousedCut) {
      emotion = 'Angry';
    } else if (score > _arousedCut) {
      emotion = 'Happy';
    } else {
      emotion = 'Relaxed';
    }
    return AlgorithmResult(
      emotion: emotion,
      arousalScore: score,
      usedBaseline: baseline != null,
      features: now,
    );
  }



  static ({double? hr, double? rmssd}) _heartRate(List<double> ppg, double fs) {
    const ({double? hr, double? rmssd}) noBeats = (hr: null, rmssd: null);
    if (ppg.isEmpty) return noBeats;
    // 0.7-3.5 Hz keeps 42-210 bpm and removes baseline wander.
    final y = Biquad.lowPass(3.5, fs).filter(Biquad.highPass(0.7, fs).filter(ppg));

    final skip = (fs * 2).floor(); // let the filters settle
    final minGap = (fs * 0.33).floor(); // <= 180 bpm
    final peaks = <int>[];
    for (var i = math.max(1, skip); i < y.length - 1; i++) {
      if (y[i] > 0 && y[i] >= y[i - 1] && y[i] > y[i + 1]) {
        if (peaks.isNotEmpty && i - peaks.last < minGap) {
          if (y[i] > y[peaks.last]) peaks[peaks.length - 1] = i;
        } else {
          peaks.add(i);
        }
      }
    }
    if (peaks.length < 3) return noBeats;

    // Drop small bumps (dicrotic notches, noise) relative to typical beats.
    final cut = 0.3 * _median([for (final p in peaks) y[p]]);
    final beats = [for (final p in peaks) if (y[p] >= cut) p];
    final ibi = [
      for (var i = 1; i < beats.length; i++) (beats[i] - beats[i - 1]) / fs * 1000.0
    ];
    if (ibi.isEmpty) return noBeats;

    // Reject intervals outside 40-180 bpm or far from the median (missed or
    // extra beats).
    final med = _median(ibi);
    final ok = [
      for (final v in ibi) v >= 333 && v <= 1500 && (v - med).abs() <= 0.3 * med
    ];
    final good = [for (var i = 0; i < ibi.length; i++) if (ok[i]) ibi[i]];
    if (good.length < 3) return noBeats;

    final diffs = [
      for (var i = 1; i < ibi.length; i++)
        if (ok[i] && ok[i - 1]) ibi[i] - ibi[i - 1]
    ];
    return (
      hr: 60000.0 / _mean(good),
      rmssd: diffs.length >= 2
          ? math.sqrt(_mean([for (final d in diffs) d * d]))
          : null,
    );
  }



  static ({double perMinute, double amplitudePerMinute, double level})
      _skinConductance(
      List<double> gsr, double fs) {
    final smooth = Biquad.lowPass(1.0, fs).filter(gsr);
    final step = math.max(1, (fs / 8).floor()); // SCRs are slow; ~8 Hz is enough
    final g = [for (var i = 0; i < smooth.length; i += step) smooth[i]];

    // Count rises of at least _minScrAmplitude from a trough to the next peak,
    // and add up their sizes.
    var count = 0;
    var amplitudeSum = 0.0;
    var trough = g[0];
    var rising = false;
    for (var i = 1; i < g.length; i++) {
      if (g[i] > g[i - 1]) {
        rising = true;
      } else if (rising && g[i] < g[i - 1]) {
        final amplitude = g[i - 1] - trough;
        if (amplitude >= _minScrAmplitude) {
          count++;
          amplitudeSum += amplitude;
        }
        trough = g[i - 1];
        rising = false;
      }
      if (g[i] < trough) trough = g[i];
    }
    final minutes = gsr.length / fs / 60.0;
    return (
      perMinute: count / minutes,
      amplitudePerMinute: amplitudeSum / minutes,
      level: _median(g),
    );
  }



  static double _mean(List<double> v) => v.reduce((a, b) => a + b) / v.length;

  static double _median(List<double> v) {
    final s = [...v]..sort();
    final m = s.length ~/ 2;
    return s.length.isOdd ? s[m] : (s[m - 1] + s[m]) / 2;
  }
}

class PhysioFeatures {
  const PhysioFeatures({
    required this.heartRate,
    required this.rmssd,
    required this.scrPerMinute,
    required this.scrAmplitudePerMinute,
    required this.skinConductance,
    required this.seconds,
  });

  /// Beats per minute; null when too few clean beats were found.
  final double? heartRate;

  /// HRV as RMSSD in ms; null when too few consecutive clean beats.
  final double? rmssd;
  final double scrPerMinute;

  /// Summed SCR rise in µS per minute.
  final double scrAmplitudePerMinute;

  /// Median skin conductance level in µS.
  final double skinConductance;
  final double seconds;

  @override
  String toString() => 'PhysioFeatures(hr: ${heartRate?.toStringAsFixed(1)}, '
      'rmssd: ${rmssd?.toStringAsFixed(1)}, '
      'scr/min: ${scrPerMinute.toStringAsFixed(1)}, '
      'scr amp/min: ${scrAmplitudePerMinute.toStringAsFixed(3)} µS, '
      'scl: ${skinConductance.toStringAsFixed(2)} µS, '
      'seconds: ${seconds.toStringAsFixed(0)})';
}

class AlgorithmResult {
  const AlgorithmResult({
    required this.emotion,
    required this.arousalScore,
    required this.usedBaseline,
    required this.features,
  });

  final String emotion;
  final double arousalScore;
  final bool usedBaseline;
  final PhysioFeatures features;
}

/// Resting baseline for the current app run.
///
/// Kept in memory only: skin conductance depends on electrode contact, so it
/// should be re-taken each time the sensor is put on.
class PhysioBaseline {
  static PhysioFeatures? current;
}
