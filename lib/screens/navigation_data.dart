import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mlkit/screens/barcode_scanner_mlkit/barcode_scanner.dart';
import 'package:flutter_mlkit/screens/camera_/camera_barcode.dart';
import 'package:flutter_mlkit/screens/camera_test_backend/templatesend.dart';
import 'package:flutter_mlkit/screens/mobile_scanner/mobile_scanner.dart';

class NavigationData extends StatefulWidget {
  const NavigationData({super.key});

  @override
  State<NavigationData> createState() => _NavigationDataState();
}

class _NavigationDataState extends State<NavigationData> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.4),
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.yellow,
                    Colors.blue.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: const Text(
                      "Camera with Barcode",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    onTap: () async {
                      await availableCameras().then(
                        (value) => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CameraBarcode(cameras: value))),
                      );
                    },
                    tileColor: Colors.purple,
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    title: const Text(
                      "Mobile Scanner",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    onTap: () async {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const Scanner()));
                    },
                    tileColor: Colors.purple,
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    title: const Text(
                      "Barcode Scanner",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BarcodeScannerView()));
                    },
                    tileColor: Colors.purple,
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    title: const Text(
                      "Template",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TemplateSend()));
                    },
                    tileColor: Colors.purple,
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
