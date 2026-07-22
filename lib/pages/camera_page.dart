import 'package:app/main.dart';
import 'package:app/pages/scan_page.dart';
import 'package:app/services/camera_model.dart';
import 'package:app/services/image_processor.dart';
import 'package:app/widgets/face_box_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';



class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  bool _isCameraInialize = false;
  bool _isDetecting = false;
  final CameraModel _cameraModel = CameraModel();
  //Fast mode is enough - we only use the bounding box, not landmarks.
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );
  Map<String, double> _emotionResults = {};
  String _predictedEmotion = "";
  //Tracks whether the last processed frame actually contained a face.
  bool _faceFound = false;
  //Surfaced in the UI: a throw in the stream callback used to look identical
  //to "no face", because both just left _faceFound false.
  String? _lastError;
  //Overlay state, all in upright-image coordinates. _analysisSize is the frame
  //the boxes were measured against, needed to scale them onto the preview.
  Rect? _faceBox;
  Rect? _cropBox;
  Size _analysisSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _inializeCamera();
    _loadModel();
  }

  @override
  void dispose(){
    //super.dispose() moved to the end: the cleanup below has to run while the
    //state is still alive, and the detector now needs closing too.
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _faceDetector.close();
    _cameraModel.dispose();
    super.dispose();
  }

  Future<void> _loadModel() async{
    await _cameraModel.loadModel();
    if(mounted){
      setState(() {
      
      });
    }
  }

  Future<void> _inializeCamera() async{
    final frontCamera = cameras.firstWhere(
      (camera)=> camera.lensDirection == CameraLensDirection.front,
      orElse: ()=>cameras.first
    );
    //Left on the default YUV420: camera_android_camerax ignores a request for
    //nv21, so asking for it just hid the fact that we still get 3 planes.
    //ImageProcessor.yuv420ToNv21() does the repack ML Kit needs.
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    try{
      await _cameraController!.initialize();
      setState(() {
        _isCameraInialize = true;
      },);
      _startDetectionStream();
    }on CameraException catch(e){
      _showSnackBar('Camera Error ${e.description}');
    } catch(e){
      _showSnackBar('Unexpected error happen $e');
    }
  } 

  void _startDetectionStream(){
    if(_cameraController == null) return;
    _cameraController!.startImageStream(
      (CameraImage cameraImage) async{
        //_loadModel() runs unawaited, so frames can arrive before the model is
        //ready. detectEmotion() used to throw here and wedge the pipeline.
        if(_isDetecting || !_cameraModel.isModelLoaded){
          return;
        }
        //Plain assignment, not setState: this is control flow, and routing it
        //through setState rebuilt the entire widget on every single frame.
        _isDetecting = true;
        try{
          //The same rotation feeds ML Kit and orientUpright() below, so the
          //bounding box and the image it is cropped from agree on coordinates.
          final rotation = ImageProcessor.rotationDegreesFor(
            _cameraController!.description,
            _cameraController!.value.deviceOrientation,
          );

          //Repack once, then feed the same buffer to ML Kit and to the crop.
          final nv21 = ImageProcessor.yuv420ToNv21(cameraImage);
          final inputImage = ImageProcessor.inputImageFromNv21(
            nv21,
            cameraImage.width,
            cameraImage.height,
            rotation,
          );
          if(inputImage == null) return;

          final face = ImageProcessor.largestFace(
            await _faceDetector.processImage(inputImage),
          );
          if(face == null){
            //Skip inference entirely. Softmax always sums to 1, so running the
            //model on a wall still produced a confident looking answer.
            if(mounted){
              setState(() {
                _faceFound = false;
                _lastError = null;
                _faceBox = null;
                _cropBox = null;
              });
            }
            return;
          }

          final upright = ImageProcessor.orientUpright(
            ImageProcessor.nv21ToRgb(nv21, cameraImage.width, cameraImage.height),
            rotation,
          );
          final crop = ImageProcessor.cropFace(
            upright,
            face.boundingBox,
            //Front camera frames are mirrored; FER-2013 faces are not.
            mirror: _cameraController!.description.lensDirection ==
                CameraLensDirection.front,
          );
          if(crop == null) return;

          final results = await _cameraModel.detectEmotion(crop);
          final emotion = _cameraModel.getPredictedEmotion(results);
          if(mounted){
            setState(() {
              _emotionResults = results;
              _predictedEmotion = emotion;
              _faceFound = true;
              _lastError = null;
              //Measured against `upright`, so the painter scales from its size.
              _faceBox = face.boundingBox;
              _cropBox = ImageProcessor.cropRect(
                face.boundingBox,
                upright.width,
                upright.height,
              );
              _analysisSize =
                  Size(upright.width.toDouble(), upright.height.toDouble());
            });
          }
        }catch(e){
          debugPrint('Detection frame failed: $e');
          if(mounted){
            setState(() {
              _lastError = '$e';
            });
          }
        }finally{
          _isDetecting = false;
        }
      }
);
  }


 void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Scanner'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.5,
            width: double.infinity,
            child: _isCameraInialize
                ? CameraPreview(
                    _cameraController!,
                    child: (_faceBox != null && !_analysisSize.isEmpty)
                        ? CustomPaint(
                            painter: FaceBoxPainter(
                              faceBox: _faceBox!,
                              cropBox: _cropBox,
                              imageSize: _analysisSize,
                            ),
                          )
                        : null,
                  )
                : Center(child: CircularProgressIndicator(),),
          ),
          //Shows the actual exception
          if(_lastError != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.red
              ),
              child: Text(
                'DETECTION ERROR: $_lastError',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          //New state: say so when no face is in frame instead of leaving the
          //last prediction on screen as though it were current.
          else if(!_faceFound)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey
              ),
              child: Text(
                "NO FACE DETECTED",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          else if(_predictedEmotion.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.green
              ),
              child: Text(
                _predictedEmotion.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          //Gated on _faceFound so stale scores are not shown under the banner.
          if(_faceFound && _emotionResults.isNotEmpty)
            Expanded(child: ListView.builder(
            itemCount: _emotionResults.length,
            itemBuilder:(context, index) {
              final emotion = _emotionResults.keys.elementAt(index);
              final confident = _emotionResults[emotion];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, //criar espaço
                children: [
                  Text(
                    emotion
                  ),
                  Text(
                    //These are softmax probabilities in 0..1, so 0.25 was
                    //rendering as "0.3%" when it meant 25%.
                    '${((confident ?? 0) * 100).toStringAsFixed(1)}%'
                  )
                ],
              );
            },
            ),
            ),
          SizedBox(height: 10),

           SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      //_startStreaming();
                      /*setState(() { 
                        isScanPageVisible = true; 
                      });*/
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ScanPage(cameraEmotion: _predictedEmotion.isEmpty? null: _predictedEmotion);
                          },
                        ),
                      );
                    },

                    child: Text(
                      "Proceed so Shimmer Sensor Scan",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}