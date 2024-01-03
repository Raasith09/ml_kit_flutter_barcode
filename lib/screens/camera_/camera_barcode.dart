import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:path_provider/path_provider.dart';

class CameraBarcode extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraBarcode({super.key, this.cameras});

  @override
  State<CameraBarcode> createState() => _CameraBarcodeState();
}

class _CameraBarcodeState extends State<CameraBarcode> {
  late CameraController _cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isCameraPaused = false;
  @override
  void initState() {
    initCamera(widget.cameras![0]);
    super.initState();
  }

  Future initCamera(CameraDescription cameraDescription) async {
// create a CameraController
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
// Next, initialize the controller. This returns a Future.
    try {
      await _cameraController.initialize().then((_) async {
        if (!mounted) return;
        await _cameraController.startImageStream((imf) => _processFrame(imf));

        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future<void> _processFrame(CameraImage cameraImage) async {
    final inputImage = _inputImageFromCameraImage(cameraImage);
    _processImage(inputImage!);
  }

  Future<void> _processImage(InputImage inputImage) async {
    final barcodes = await _barcodeScanner.processImage(inputImage);
    for (Barcode barcode in barcodes) {
      print('Type: ${barcode.type}, Value: ${barcode.value}');
    }
    // //   _cameraController.stopImageStream();
    // if (mounted) {
    //   setState(() {});
    // }
    if (!_isCameraPaused) {
      // _isCameraPaused = true;
      // _cameraController.pausePreview();

      // Capture and save the image
      // XFile imageFile = await _cameraController.takePicture();
      // Uint8List imageBytes = await imageFile.readAsBytes();
      // img.Image? image = img.decodeJpg(imageBytes);
      // await saveImage(image!);

      // ... (rest of the code)
    }
  }

  Future<void> saveImage(img.Image image) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + '/qrcodes';
    await Directory(path).create(recursive: true);
    final filePath = '$path/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(filePath).writeAsBytes(img.encodeJpg(image));
    print('Cropped QR code image saved to: $filePath');
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: _cameraController.value.isInitialized
                ? CameraPreview(_cameraController)
                : const Center(child: CircularProgressIndicator())));
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = widget.cameras![0];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_cameraController.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}


 // Convert camera image to InputImage for ML Kit
    // final imageFormat = cameraImage.format;
    // final planeData = cameraImage.planes.first;
    // final bytes = planeData.bytes;
    // final inputImage = InputImage.fromPlatformImage(
    //     PlatformImage(
    //         width: cameraImage.width,
    //         height: cameraImage.height,
    //         planeData: planes),
    //     planeData.bytes.length,
    //     imageFormat,
    //     pixelFormat: InputImagePixelFormat.yuv420);

    // // Process image with ML Kit for barcodes
    // final Future<Barcode> mlKitBarcode =
    //     barcodeScanner.processImage(inputImage);
