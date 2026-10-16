import 'dart:math' as math;


class Biquad {
  Biquad._(this.b0, this.b1, this.b2, this.a1, this.a2);

  factory Biquad.lowPass(double f0, double fs) {
    final w0 = 2 * math.pi * f0 / fs;
    final alpha = math.sin(w0) / (2 * _q);
    final c = math.cos(w0);
    final a0 = 1 + alpha;
    return Biquad._((1 - c) / 2 / a0, (1 - c) / a0, (1 - c) / 2 / a0,
        -2 * c / a0, (1 - alpha) / a0);
  }

  factory Biquad.highPass(double f0, double fs) {
    final w0 = 2 * math.pi * f0 / fs;
    final alpha = math.sin(w0) / (2 * _q);
    final c = math.cos(w0);
    final a0 = 1 + alpha;
    return Biquad._((1 + c) / 2 / a0, -(1 + c) / a0, (1 + c) / 2 / a0,
        -2 * c / a0, (1 - alpha) / a0);
  }

  static final double _q = 1 / math.sqrt(2);
  final double b0, b1, b2, a1, a2;

  List<double> filter(List<double> x) {
    if (x.isEmpty) return const [];
    // Start in steady state on the first sample to avoid an edge transient.
    final dcGain = (b0 + b1 + b2) / (1 + a1 + a2);
    var x1 = x[0], x2 = x[0];
    var y1 = x[0] * dcGain, y2 = y1;
    final y = List<double>.filled(x.length, 0);
    for (var i = 0; i < x.length; i++) {
      final yi = b0 * x[i] + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2;
      x2 = x1;
      x1 = x[i];
      y2 = y1;
      y1 = yi;
      y[i] = yi;
    }
    return y;
  }
}
