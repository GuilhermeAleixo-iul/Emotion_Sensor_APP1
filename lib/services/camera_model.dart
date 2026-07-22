
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import 'image_processor.dart';

class CameraModel{
  late Interpreter _interpreter;
  late List<String> _labels;
  bool _isModelLoaded = false;
  bool get isModelLoaded => _isModelLoaded;
  


  Future<void> loadModel() async{
    try{
      _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n').where((label)=> label.isNotEmpty).toList(); //use a new line separated
      _isModelLoaded = true;
    }catch(e){
     debugPrint("Failed to load Model $e" );
     _isModelLoaded = false;
    }
  }
   void dispose(){
    //Guarded: _interpreter is `late`, so closing it after a failed loadModel()
    //threw LateInitializationError on top of the original failure.
    if(_isModelLoaded){
      _interpreter.close();
    }
   }

  Future<Map<String, double>> detectEmotion(img.Image image) async{
    if(!_isModelLoaded){
      throw Exception('Model is not loaded');
    } 
    try{
      final input = ImageProcessor.toModelInput(image, color: ColorMode.ferMatched);
      final inputData = input.reshape([1, 224, 224, 3]);
      var output = List.filled(1*_labels.length, 0.0).reshape([1, _labels.length]);
      _interpreter.run(inputData, output);
      List<double> probabilitys = output[0].cast<double>();
      Map<String, double> results = {};
      for(int i=0; i < _labels.length; i++){
        results[_labels[i]] = probabilitys[i];
        
      }
      return results;
    }catch(e){
      debugPrint("Error during emotion Detector $e");
      rethrow;
    }
  } 

  String getPredictedEmotion(Map<String, double> results){
    String maxEmotion = '';
    double maxConfidence = 0.0;
    results.forEach((emotion, confidence){
      if(confidence > maxConfidence){
        maxConfidence = confidence;
        maxEmotion = emotion;
      }
    });
    return maxEmotion;
  }

}