import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mlkit/services/apiservices.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image/image.dart' as img;

class TemplateSend extends StatefulWidget {
  const TemplateSend({super.key});

  @override
  State<TemplateSend> createState() => _TemplateSendState();
}

class _TemplateSendState extends State<TemplateSend> {
  // List<Uint8List> imageBytesList = [];
  List<Uint8List> rotatedImages = [];
  BarcodeCapture? barcode;
  bool image = false;

  MobileScannerController controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      torchEnabled: false,
      returnImage: true);
  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCircle(
      center: MediaQuery.of(context).size.center(Offset.zero),
      radius: 250.0,
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(150),
                    child: SizedBox(
                      height: 250,
                      width: 250,
                      child: MobileScanner(
                        fit: BoxFit.cover,
                        controller: controller,
                        onDetect: (capture) async {
                          barcode = capture;
                          final Uint8List? imageBytes = barcode!.image;

                          if (imageBytes!.isNotEmpty && image == false) {
                            image = true;

                            _rotateImages(imageBytes);
                            // final originalImage = img.decodeImage(capture.image!);
                            // imageBytesList = [
                            //   originalImage!.getBytes(), // Original image bytes
                            //   img.copyRotate(originalImage, angle: 90).getBytes(),
                            //   img.copyRotate(originalImage, angle: 180).getBytes(),
                            //   img.copyRotate(originalImage, angle: 270).getBytes()
                            // ];
                            // print("hi");
                            // print(imageBytesList);
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            rotatedImages.isNotEmpty
                ? SizedBox(
                    height: 100,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: rotatedImages.length,
                        itemBuilder: (context, index) {
                          return Image.memory(
                            rotatedImages[index],
                            height: 100,
                            width: 100,
                          );
                        }),
                  )
                : Container(),
            const SizedBox(height: 100),
            GestureDetector(
              onTap: () async {
                if (rotatedImages.isNotEmpty) {
                  Map<String, List> map = {"data": rotatedImages};
                  var getData = await ApiServices().sendImages(map);
                  print(getData);
                }
              },
              child: Container(
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.blue, borderRadius: BorderRadius.circular(5)),
                child: const Center(
                  child: Text(
                    "Send",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _rotateImages(Uint8List imageBytes) async {
    // Decode the original image
    img.Image originalImage = img.decodeImage(imageBytes)!;

    // Rotate the image in four directions (0, 90, 180, 270 degrees)
    for (int degrees in [0, 90, 180, 270]) {
      img.Image rotatedImage = img.copyRotate(originalImage, angle: degrees);
      print(degrees);
      // Encode the rotated image to bytes
      Uint8List rotatedImageBytes =
          Uint8List.fromList(img.encodePng(rotatedImage));

      // Add the rotated image bytes to the list
      rotatedImages.add(rotatedImageBytes);
    }

    return;
  }
}

class Base64Image extends StatelessWidget {
  final String base64Image;

  const Base64Image({super.key, required this.base64Image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.memory(
        base64Decode(base64Image),
        fit: BoxFit.cover,
        height: 300,
        width: 300,
      ),
    );
  }
}
