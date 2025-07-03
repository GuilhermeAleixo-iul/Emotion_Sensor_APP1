import 'package:flutter/services.dart';

class ShimmerService {
  ShimmerService._();
  
  static const MethodChannel _channel = 
      MethodChannel('com.example.emotion_sensor/shimmer');

  static const EventChannel  event_channel =
      EventChannel('com.example.emotion_sensor/shimmer/events');


  static Future<void> connect() async {
    await _channel.invokeMethod('connect');
  }

  static Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
  }

  static Future<void> startStreaming() async {
    await _channel.invokeMethod('startStreaming');
  }

  static Future<void> stopStreaming() async {
    await _channel.invokeMethod('stopStreaming');
  }
}