import 'dart:math' as math;

import 'package:app/models/sensor_data.dart';
import 'package:app/services/biquad.dart';

/// Scan-level features for the no-baseline arousal model.
class ScanFeatures {
  static const names = [
    // skin conductance
    'scr_rate', 'rel_scr_amp', 'scr_max_rel', 'scl_slope_rel', 'eda_cv',
    'log_scl',
    // pulse
    'hr', 'hr_slope', 'hr_cv', 'rmssd_rel', 'pnn50', 'log_rmssd',
    'ppg_amp_cv', 'ppg_amp_slope_rel',
  ];

  /// Rise in conductance (µS) that counts as a skin conductance response.
  static const double _minScrAmplitude = 0.03;

  /// Features of one stretch of samples. GSR arrives as resistance in kΩ
  /// (converted to µS here) and PPG in mV; missing values (-1) are skipped.
  static Map<String, double> fromSamples(List<SensorData> samples, double fs) {
    final ppg = <double>[];
    final gsr = <double>[];
    for (final d in samples) {
      if (d.ppg != null && d.ppg! > 0) ppg.add(d.ppg!);
      if (d.grs != null && d.grs! > 0) gsr.add(1000.0 / d.grs!);
    }
    return compute(ppg, gsr, fs);
  }

  static Map<String, double> compute(
      List<double> ppg, List<double> gsrUs, double fs) {
    final f = {for (final n in names) n: double.nan};
    if (gsrUs.isNotEmpty) _eda(gsrUs, fs, f);
    if (ppg.isNotEmpty) _pulse(ppg, fs, f);
    return f;
  }


  static void _eda(List<double> gsrUs, double fs, Map<String, double> f) {
    final minutes = gsrUs.length / fs / 60.0;
    final smooth = Biquad.lowPass(1.0, fs).filter(gsrUs);
    final step = math.max(1, (fs / 8).floor());
    final g = [for (var i = 0; i < smooth.length; i += step) smooth[i]];
    final tg = [for (var i = 0; i < g.length; i++) i * step / fs];

    // Rises of at least _minScrAmplitude from a trough to the next peak.
    final amps = <double>[];
    var trough = g[0];
    var rising = false;
    for (var i = 1; i < g.length; i++) {
      if (g[i] > g[i - 1]) {
        rising = true;
      } else if (rising && g[i] < g[i - 1]) {
        final a = g[i - 1] - trough;
        if (a >= _minScrAmplitude) amps.add(a);
        trough = g[i - 1];
        rising = false;
      }
      if (g[i] < trough) trough = g[i];
    }

    final scl = _median(g);
    f['scr_rate'] = amps.length / minutes;
    if (scl > 0) {
      f['rel_scr_amp'] = _sum(amps) / minutes / scl;
      f['scr_max_rel'] = (amps.isEmpty ? 0.0 : amps.reduce(math.max)) / scl;
    }
    if (scl > 0 && g.every((v) => v > 0)) {
      f['scl_slope_rel'] = _slopePerMinute(tg, [for (final v in g) math.log(v)]);
      // Spread after removing the straight-line trend, relative to the level.
      final b = _slopePerMinute(tg, g) / 60.0;
      final gm = _mean(g), tm = _mean(tg);
      final resid = [for (var i = 0; i < g.length; i++) g[i] - (gm + b * (tg[i] - tm))];
      f['eda_cv'] = _std(resid) / scl;
      f['log_scl'] = math.log(scl);
    }
  }

  // ---------------- pulse ----------------

  static void _pulse(List<double> ppg, double fs, Map<String, double> f) {
    // 0.7-3.5 Hz keeps 42-210 bpm and removes baseline wander.
    final y = Biquad.lowPass(3.5, fs).filter(Biquad.highPass(0.7, fs).filter(ppg));
    final skip = (fs * 2).floor(); // let the filters settle
    final minGap = (fs * 0.33).floor(); // <= 180 bpm
    var peaks = <int>[];
    for (var i = math.max(1, skip); i < y.length - 1; i++) {
      if (y[i] > 0 && y[i] >= y[i - 1] && y[i] > y[i + 1]) {
        if (peaks.isNotEmpty && i - peaks.last < minGap) {
          if (y[i] > y[peaks.last]) peaks[peaks.length - 1] = i;
        } else {
          peaks.add(i);
        }
      }
    }
    if (peaks.length < 3) return;
    // Drop small bumps (dicrotic notches, noise) relative to typical beats.
    final cut = 0.3 * _median([for (final p in peaks) y[p]]);
    peaks = [for (final p in peaks) if (y[p] >= cut) p];
    final ibi = [
      for (var i = 1; i < peaks.length; i++) (peaks[i] - peaks[i - 1]) / fs * 1000.0
    ];
    if (ibi.isEmpty) return;
    // Reject intervals outside 40-180 bpm or far from the median.
    final med = _median(ibi);
    final ok = [
      for (final v in ibi) v >= 333 && v <= 1500 && (v - med).abs() <= 0.3 * med
    ];
    // Beat amplitude: the peak above the lowest point since the previous peak.
    final amp = [
      for (var k = 1; k < peaks.length; k++)
        y[peaks[k]] - y.sublist(peaks[k - 1], peaks[k]).reduce(math.min)
    ];
    final t = [for (var k = 1; k < peaks.length; k++) peaks[k] / fs];

    final idx = [for (var i = 0; i < ibi.length; i++) if (ok[i]) i];
    if (idx.length < 3) return;
    final good = [for (final i in idx) ibi[i]];
    final tOk = [for (final i in idx) t[i]];
    final hrI = [for (final v in good) 60000.0 / v];
    final meanIbi = _mean(good);
    f['hr'] = 60000.0 / meanIbi;
    f['hr_slope'] = _slopePerMinute(tOk, hrI);
    f['hr_cv'] = _std(hrI) / _mean(hrI);

    final d = [
      for (var i = 1; i < ibi.length; i++)
        if (ok[i] && ok[i - 1]) ibi[i] - ibi[i - 1]
    ];
    if (d.length >= 2) {
      final rmssd = math.sqrt(_mean([for (final v in d) v * v]));
      f['rmssd_rel'] = rmssd / meanIbi;
      f['log_rmssd'] = rmssd > 0 ? math.log(rmssd) : double.nan;
      f['pnn50'] = d.where((v) => v.abs() > 50).length / d.length;
    }
    final a = [for (final i in idx) amp[i]];
    final am = _mean(a);
    if (a.length >= 3 && am > 0) {
      f['ppg_amp_cv'] = _std(a) / am;
      f['ppg_amp_slope_rel'] = _slopePerMinute(tOk, a) / am;
    }
  }

  /// Least-squares slope of [y] against time in seconds, per minute.
  static double _slopePerMinute(List<double> t, List<double> y) {
    if (y.length < 3) return double.nan;
    final tm = _mean(t), ym = _mean(y);
    var num = 0.0, den = 0.0;
    for (var i = 0; i < y.length; i++) {
      num += (t[i] - tm) * (y[i] - ym);
      den += (t[i] - tm) * (t[i] - tm);
    }
    return den == 0 ? double.nan : num / den * 60.0;
  }

  static double _sum(List<double> v) => v.fold(0.0, (a, b) => a + b);

  static double _mean(List<double> v) => _sum(v) / v.length;

  /// Population standard deviation, as numpy's default.
  static double _std(List<double> v) {
    final m = _mean(v);
    return math.sqrt(_mean([for (final x in v) (x - m) * (x - m)]));
  }

  static double _median(List<double> v) {
    final s = [...v]..sort();
    final m = s.length ~/ 2;
    return s.length.isOdd ? s[m] : (s[m - 1] + s[m]) / 2;
  }
}
