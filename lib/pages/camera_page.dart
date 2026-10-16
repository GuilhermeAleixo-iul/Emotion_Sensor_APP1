import 'package:app/main.dart';
import 'package:app/pages/scan_page.dart';
import 'package:app/services/camera_model.dart';
import 'package:app/services/image_processor.dart';
import 'package:app/theme/emotion_visuals.dart';
import 'package:app/widgets/emotion_bar_chart.dart';
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
  //The camera result is the average of every frame with a face since the page
  //opened (or since Restart), not the last frame: single frames flicker with
  //blinks, head turns and speech.
  final Map<String, double> _probabilitySums = {};
  int _framesAveraged = 0;
  DateTime? _averageStartedAt;
  DateTime? _lastAveragedAt;
  //Off while the sensor scan is on top, so frames from then don't count.
  bool _collecting = true;
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
          if(mounted){
            setState(() {
              if(_collecting){
                results.forEach((label, p){
                  _probabilitySums[label] = (_probabilitySums[label] ?? 0) + p;
                });
                _framesAveraged++;
                final now = DateTime.now();
                _averageStartedAt ??= now;
                _lastAveragedAt = now;
              }
              _faceFound = true;
              _lastError = null;
              //Measured against `upright`, so the painter scales from its size.
              _faceBox = face.boundingBox;
              // _cropBox = ImageProcessor.cropRect(
              //   face.boundingBox,
              //   upright.width,
              //   upright.height,
              // );
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


  Map<String, double> get _averageScores => {
        for (final e in _probabilitySums.entries) e.key: e.value / _framesAveraged,
      };

  /// The emotion with the highest average probability; empty before any face.
  String get _averageEmotion => _framesAveraged == 0
      ? ''
      : _cameraModel.getPredictedEmotion(_averageScores);

  double get _averagedSeconds =>
      _averageStartedAt == null || _lastAveragedAt == null
          ? 0
          : _lastAveragedAt!.difference(_averageStartedAt!).inMilliseconds / 1000;

  void _restartAverage() {
    setState(() {
      _probabilitySums.clear();
      _framesAveraged = 0;
      _averageStartedAt = null;
      _lastAveragedAt = null;
    });
  }

  Future<void> _proceedToSensorScan() async {
    final emotion = _averageEmotion;
    setState(() => _collecting = false);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanPage(cameraEmotion: emotion.isEmpty ? null : emotion),
      ),
    );
    // Back from the sensor scan: a new attempt starts a new average.
    if (!mounted) return;
    _restartAverage();
    setState(() => _collecting = true);
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
      appBar: AppBar(title: const Text('Facial Scan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              height: height * 0.45,
              width: double.infinity,
              // The preview takes the full width at its own aspect ratio
              // (height unbounded, so it isn't stretched); whatever is taller
              // than the box is cropped evenly top and bottom. The face box
              // overlay is laid out with the preview, so it stays aligned.
              child: _isCameraInialize
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: OverflowBox(
                        minHeight: 0,
                        maxHeight: double.infinity,
                        child: CameraPreview(
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
                        ),
                      ),
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
            ),
          ),
          // Status banner: error takes priority, then no-face, then the
          // detected emotion.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _CameraStatusBanner(
              error: _lastError,
              faceFound: _faceFound,
              emotion: _averageEmotion,
            ),
          ),
          if (_framesAveraged > 0) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Average of $_framesAveraged frames over '
                      '${_averagedSeconds.toStringAsFixed(0)} s',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _restartAverage,
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: const Text('Restart'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: EmotionBarChart(scores: _averageScores),
              ),
            ),
          ] else
            const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _proceedToSensorScan,
              icon: const Icon(Icons.sensors),
              label: const Text('Proceed to Sensor Scan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraStatusBanner extends StatelessWidget {
  const _CameraStatusBanner({
    required this.error,
    required this.faceFound,
    required this.emotion,
  });

  final String? error;
  final bool faceFound;
  final String emotion;

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;
    late final String text;

    if (error != null) {
      icon = Icons.error_outline;
      color = const Color(0xFFEF4444);
      text = 'Detection error';
    } else if (!faceFound) {
      icon = Icons.face_retouching_off;
      color = const Color(0xFF94A3B8);
      text = 'No face detected';
    } else if (emotion.isNotEmpty) {
      final v = emotionVisual(emotion);
      icon = v.icon;
      color = v.color;
      text = v.label;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}