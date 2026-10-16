import 'dart:math' as math;

import 'package:app/models/sensor_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Consistent colors per signal, so title dots and lines match everywhere.
class SensorColors {
  SensorColors._();
  static const accel = Color(0xFF6366F1); // indigo
  static const ppg = Color(0xFFEF4444); // red (heart)
  static const gsr = Color(0xFF14B8A6); // teal
  static const emg = Color(0xFFF59E0B); // amber
}

/// A single sensor channel plotted against elapsed time.
class SensorLineChart extends StatelessWidget {
  const SensorLineChart({
    super.key,
    required this.data,
    required this.selector,
    required this.color,
    this.windowSize = 10,
  });

  final List<SensorData> data;
  final double? Function(SensorData) selector;
  final Color color;
  final double windowSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Keep only finite samples that actually have this channel.
    final valid = <SensorData>[];
    for (final d in data) {
      final y = selector(d);
      if (d.timeStamp != null &&
          d.timeStamp!.isFinite &&
          y != null &&
          y.isFinite) {
        valid.add(d);
      }
    }

    if (valid.length < 2) {
      return Center(
        child: Text(
          'Waiting for data…',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      );
    }

    final oldest = valid.first.timeStamp!;
    final range = valid.last.timeStamp! - oldest;
    final window = windowSize <= 0 ? 1.0 : windowSize;

    final spots = <FlSpot>[
      for (final d in valid)
        FlSpot(
          range == 0 ? 0.0 : (d.timeStamp! - oldest) / range * window,
          selector(d)!,
        ),
    ];

    // Nice, rounded y bounds so labels read 100/150/200, not 114.3/154.8/195.2.
    var dataMin = spots.first.y, dataMax = spots.first.y;
    for (final s in spots) {
      dataMin = math.min(dataMin, s.y);
      dataMax = math.max(dataMax, s.y);
    }
    final bounds = _niceBounds(dataMin, dataMax);
    final labelStyle = TextStyle(fontSize: 10, color: scheme.onSurfaceVariant);
    final decimals = bounds.step < 1 ? 1 : 0;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: window,
        minY: bounds.min,
        maxY: bounds.max,
        clipData: const FlClipData.all(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: bounds.step,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: window / 2,
              getTitlesWidget: (value, meta) {
                // Drop the far-left tick so it doesn't collide with the y-axis.
                if (value <= 0.01) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('${value.toStringAsFixed(0)}s', style: labelStyle),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: bounds.step,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(decimals),
                style: labelStyle,
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            dotData: const FlDotData(show: false),
            barWidth: 1.6,
            color: color,
          ),
        ],
      ),
    );
  }

  // Rounds [min,max] outward to ~2 intervals with a 1/2/5×10ⁿ step.
  static ({double min, double max, double step}) _niceBounds(
    double min,
    double max,
  ) {
    if (min == max) {
      min -= 1;
      max += 1;
    }
    final rawStep = (max - min) / 2;
    final mag = math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final norm = rawStep / mag;
    final double step = norm < 1.5
        ? mag
        : norm < 3
            ? 2 * mag
            : norm < 7
                ? 5 * mag
                : 10 * mag;
    return (
      min: (min / step).floor() * step,
      max: (max / step).ceil() * step,
      step: step,
    );
  }
}

/// Titled card wrapper for a chart, with a color dot tying the title to the line.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.color,
    required this.child,
  });

  final String title;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
