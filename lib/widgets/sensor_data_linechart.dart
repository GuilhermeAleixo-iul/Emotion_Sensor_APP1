import "package:app/models/sensor_data.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";

class SensorDataLinechart extends StatelessWidget {
  const SensorDataLinechart({super.key, required this.sensorDataList});
  final List<SensorData> sensorDataList;

  @override
  Widget build(BuildContext context) {
    double oldestTimeStamp = 0.0;
    double latestedTimeStamp = 0.0;
    if(sensorDataList.isNotEmpty ) {
          latestedTimeStamp = sensorDataList.last.timeStamp!;
          oldestTimeStamp = sensorDataList.first.timeStamp!;
    }

    final timeStampRage = latestedTimeStamp - oldestTimeStamp;

    final spots = sensorDataList.map((e) {
      final relativeTimeStamp = (e.timeStamp! - oldestTimeStamp) / timeStampRage * 6.0;
      return FlSpot(
        relativeTimeStamp, e.accelX!
      );
    },);
    return LineChart(
      LineChartData(
        minX: 0.0,
        maxX: 6.0,
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots.toList(),
            dotData: FlDotData(show: false), 
            barWidth: 2
          )
        ]
      )
    );
  }
}
