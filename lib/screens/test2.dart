import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';

class QRCodeCropperPage extends StatefulWidget {
  @override
  _QRCodeCropperPageState createState() => _QRCodeCropperPageState();
}

class _QRCodeCropperPageState extends State<QRCodeCropperPage> {
  Uint8List? _capturedImageBytes;

  @override
  void initState() {
    super.initState();
    _captureAndCropQRCode();
  }

  Future<void> _captureAndCropQRCode() async {
    // Replace this with your image capture logic
    // For example, you can use the camera package to capture images
    // Here, we are just using a placeholder image
    // Ensure you replace this logic with actual image capture code
    Uint8List capturedBytes = await _captureImage();

    // Crop the QR code from the captured image
    Uint8List croppedBytes = _cropQRCode(capturedBytes);

    // Save the cropped image to the gallery
    await _saveImageToGallery(croppedBytes);

    setState(() {
      _capturedImageBytes = croppedBytes;
    });
  }

  Future<Uint8List> _captureImage() async {
    // Replace this with your actual image capture logic
    // For example, you can use the camera package to capture images
    // Here, we are just using a placeholder image
    // Ensure you replace this logic with actual image capture code
    return Uint8List.fromList(
        img.encodePng(img.Image(height: 200, width: 200)));
  }

  Uint8List _cropQRCode(Uint8List imageBytes) {
    // Decode the image from bytes
    img.Image image = img.decodeImage(imageBytes)!;

    // Find QR code boundaries (replace this with actual QR code detection logic)
    int left = 50;
    int top = 50;
    int width = 100;
    int height = 100;

    // Crop the QR code from the image
    img.Image croppedImage =
        img.copyCrop(image, y: left, x: top, width: width, height: height);

    // Encode the cropped image to bytes
    return Uint8List.fromList(img.encodePng(croppedImage));
  }

  Future<void> _saveImageToGallery(Uint8List imageBytes) async {
    // Save the image to the gallery
    final result = await ImageGallerySaver.saveImage(imageBytes);
    print('Image saved to gallery: $result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Cropper'),
      ),
      body: Center(
        child: _capturedImageBytes != null
            ? Image.memory(_capturedImageBytes!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: QRCodeCropperPage(),
  ));
}






//https://chat.openai.com/share/249a8d3a-5fff-4551-83f8-5f5460563afb