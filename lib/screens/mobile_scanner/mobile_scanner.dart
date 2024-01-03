import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  late bool isNavigationCompleted;
  late List<Offset> qrCorners;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerState? state;
  BarcodeCapture? barcode;
  MobileScannerController mbctrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      torchEnabled: false,
      returnImage: true);

  @override
  void initState() {
    isNavigationCompleted = false;
    super.initState();
  }

  @override
  void dispose() {
    isNavigationCompleted = false;
    mbctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 13, 109, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Scan QR Code",
                style: TextStyle(
                    fontSize: 24,
                    color: Color(0xff3D3D3D),
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
                height: (MediaQuery.of(context).size.width < 400 ||
                        MediaQuery.of(context).size.height < 400)
                    ? 250.0
                    : 500.0,
                width: (MediaQuery.of(context).size.width < 400 ||
                        MediaQuery.of(context).size.height < 400)
                    ? 250.0
                    : 500.0,
                child: Stack(
                  children: [
                    MobileScanner(
                      fit: BoxFit.contain,
                      controller: mbctrl,
                      onDetect: (capture) async {
                        barcode = capture;

                        //       final List<Barcode> barcodes = capture.barcodes;
                        Uint8List? imageBytes = capture.image;

                        // for (final barcode in barcodes) {
                        //   debugPrint('Barcode found! ${barcode.rawValue}');
                        // }

                        if (imageBytes!.isNotEmpty) {
                          mbctrl.stop();
                          img.Image image = img.decodeImage(imageBytes!)!;
                          qrCorners = barcode!.barcodes[0].corners;
                          int x1 = qrCorners[0].dx.toInt();
                          int y1 = qrCorners[0].dy.toInt();
                          int x2 = qrCorners[2].dx.toInt();
                          int y2 = qrCorners[2].dy.toInt();

                          img.Image croppedImage = img.copyCrop(
                            image,
                            height: image.height,
                            width: image.width,
                            x: x2 - x1,
                            y: y2 - y1,
                          );

                          await saveCroppedImageToGallery(croppedImage);
                          //  saveImageToGallerY(image);
                          // print(barcode!.barcodes[0].corners[0].dx);
                          // print(barcode!.barcodes[0].corners[0].dy);
                        }
                      },
                    ),
                    // MobileScanner(
                    //   // fit: BoxFit.contain,
                    //   controller: mbctrl,
                    //   onDetect: (capture) async {
                    //     final List<Barcode> barcodes = capture.barcodes;
                    //     for (final barcode in barcodes) {
                    //       // widget;
                    //       if (barcode.rawValue!.length > 6) {
                    //         if (context.mounted) {
                    //           if (!isNavigationCompleted) {
                    //             // isNavigationCompleted = true;
                    //             final Uint8List? image = capture.image;
                    //             await saveImageToGallery(image!);
                    //           }
                    //         }
                    //       } else {
                    //         ScaffoldMessenger.of(context).showSnackBar(
                    //             const SnackBar(
                    //                 duration: Duration(seconds: 3),
                    //                 backgroundColor:
                    //                     Color.fromARGB(255, 244, 184, 54),
                    //                 content:
                    //                     Text('Please scan a valid QR stamp')));
                    //       }
                    //     }
                    //   },
                    // ),
                  ],
                )),
            const SizedBox(height: 50),
            const Text(
              "Place a barcode/qrcode inside the\nviewfinder rectangle to do it.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xff3D3D3D),
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveImageToGallerY(Uint8List imageBytes) async {
    final fileName =
        'captured_image_${DateTime.now().microsecondsSinceEpoch}.jpg'; // Customize filename
    await ImageGallerySaver.saveImage(imageBytes, name: fileName);
    print('Image saved to gallery!');
  }
}

Future<void> saveImageToGallery(Uint8List imageBytes) async {
  if (imageBytes.isNotEmpty) {
    final fileName =
        'captured_image_${DateTime.now().microsecondsSinceEpoch}.jpg'; // Customize filename
    await ImageGallerySaver.saveImage(imageBytes, name: fileName);
    print('Image saved to gallery!');
  } else {
    print("error");
  }
}

Future<void> saveCroppedImageToGallery(img.Image croppedImage) async {
  final bytes = img.encodeJpg(croppedImage);
  final result = await ImageGallerySaver.saveImage(bytes);
  if (result) {
    print('QR code image saved to gallery successfully!');
  } else {
    print('Failed to save QR code image to gallery.');
  }
}
