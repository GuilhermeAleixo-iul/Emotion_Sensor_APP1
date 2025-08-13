import 'package:app/data/data_source/sensor_local_data_source.dart';
import 'package:app/main.dart';
import 'package:app/models/scan_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ScanHistoryPage> {
  final dataSource = SensorLocalDataSource(isar: isar);
  List<ScanSession> _scanSessions = [];

  @override
  void initState() {
    super.initState();
    _loadScanSessions();
  }

  void _loadScanSessions() async {
    final data = await dataSource.getScanSessions();
    setState((){
      _scanSessions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataFormat = DateFormat('EEEE, MMMM d, yyyy – hh:mm a');
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Scan'),
      ),
      body: ListView.builder(
        itemCount: _scanSessions.length,
        itemBuilder: (context, index) {
          final scanSession = _scanSessions[index];
          return ListTile(
            title: Text(dataFormat.format(
              scanSession.startTime
            )),
          );
        },
      ),
    );
  }
}