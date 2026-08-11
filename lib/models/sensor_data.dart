// Plain domain model — no database coupling. Persistence mapping now lives in
// SensorLocalDataSource. (The old toCollection() silently dropped ppg and emg.)
class SensorData {
  final double? timeStamp;
  final double? accelX;
  final double? grs;
  final double? ppg;
  final double? emg;

  const SensorData({
    this.timeStamp,
    this.accelX,
    this.grs,
    this.ppg,
    this.emg,
  });
}
