import 'package:app/models/scan_session.dart';
import 'package:app/widgets/charts/accel_chart.dart';
import 'package:app/widgets/charts/emg_chart.dart';
import 'package:app/widgets/charts/grs_chart.dart';
import 'package:flutter/material.dart';

class ScanDetailPage extends StatefulWidget {
  const ScanDetailPage({super.key, required this.scanSession});
  final ScanSession scanSession;

  @override
  State<ScanDetailPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ScanDetailPage> {
  @override
  Widget build(BuildContext context) {
    debugPrint('sensorDataListLength${widget.scanSession.sensorDataList.length}');
    double elapseTime = 10.0;
    if(widget.scanSession.sensorDataList.length >= 2) {
      elapseTime = widget.scanSession.sensorDataList.last.timeStamp! - widget.scanSession.sensorDataList.first.timeStamp!;
      elapseTime = elapseTime / 1000.0;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Scan Detail Page')),
      body: Column(
        children: [
          Expanded(
            child: AccelerometerChart(
              sensorDataList: widget.scanSession.sensorDataList,
              windowSize: elapseTime,
            ),
          ),
          Expanded(
            child: EmgChart(
              sensorDataList: widget.scanSession.sensorDataList,
              windowSize: elapseTime,
            ),
          ),
          Expanded(
            child: GrsChart(
              sensorDataList: widget.scanSession.sensorDataList,
              windowSize: elapseTime,
            ),
          ),
        ],
      ),
    );
  }
}
