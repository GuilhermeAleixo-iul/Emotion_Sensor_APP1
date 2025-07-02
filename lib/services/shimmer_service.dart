import 'package:flutter/services.dart';

class ShimmerService {
  static const MethodChannel _channel = 
      MethodChannel('com.example.emotion_sensor/shimmer');

  static Future<void> connect() async {
    await _channel.invokeMethod('connect');
  }

  static Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
  }
}