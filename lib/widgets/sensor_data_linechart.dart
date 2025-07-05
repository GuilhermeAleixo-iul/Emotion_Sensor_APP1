import "package:app/models/sensor_data.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";

class SensorDataLinechart extends StatelessWidget {
  const SensorDataLinechart({super.key, required this.sensorDataList});
  final List<SensorData> sensorDataList;

  @override
  Widget build(BuildContext context) {
    final validData =
        sensorDataList
            .where(
              (data) =>
                  data.timeStamp != null &&
                  data.accelX != null &&
                  data.timeStamp!.isFinite &&
                  data.accelX!.isFinite,
            )
            .toList();

    List<FlSpot> spots = [];

    if(validData.isNotEmpty){
      final latestTimeStamp = sensorDataList.last.timeStamp!;
      final oldestTimeStamp = sensorDataList.first.timeStamp!;
      final timeStampRage = latestTimeStamp - oldestTimeStamp;

      for(int i = 0; i < validData.length; i++) {
        final e = validData[i];
        final relativeTimeStamp =
            (e.timeStamp! - oldestTimeStamp) / timeStampRage * 10.0;
        spots.add(FlSpot(relativeTimeStamp, e.accelX!));
      }
    }

    return LineChart(
      duration: Duration(microseconds: 100),
      LineChartData(
        minX: 0.0,
        maxX: 10.0,
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}s',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: 0.5,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            dotData: FlDotData(show: false),
            barWidth: 2,
            color: Colors.blue
          ),
        ],
      ),
    );
  }
}
