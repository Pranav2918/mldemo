import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

import 'image_preview.dart';

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key});

  @override
  State<FaceDetectionPage> createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  late ImagePicker imagePicker;
  String? pickedImagePath;
  ui.Image? faceDetectImage;
  List<Face> faces = [];
  ByteData? imgBytes;
  static const kCanvasSize = 2000.0;

  void _pickImageAndProcess({required ImageSource source}) async {
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage == null) {
      return;
    }
    setState(() {
      pickedImagePath = pickedImage.path;
    });

    try {
      final inputImage = InputImage.fromFilePath(pickedImagePath!);
      final FaceDetector faceDetector = FaceDetector(
          options: FaceDetectorOptions(
              performanceMode: FaceDetectorMode.accurate, minFaceSize: 0.0));
      faces = await faceDetector.processImage(inputImage);
      var bytesFromImageFileDATA = await pickedImage.readAsBytes();
      decodeImageFromList(bytesFromImageFileDATA).then((imgData) async {
        final List<Rect> rects = [];

        if (faces.isNotEmpty) {
          for (var i = 0; i < faces.length; i++) {
            rects.add(faces[i].boundingBox);
          }
        } else {}

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(
            recorder,
            Rect.fromPoints(
                Offset(0.0, 0.0), Offset(kCanvasSize, kCanvasSize)));

        final Paint paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0
          ..strokeWidth = 10.0
          ..color = Colors.yellow;

        canvas.drawImage(imgData, Offset.zero, Paint());
        for (var i = 0; i < faces.length; i++) {
          canvas.drawRect(rects[i], paint);
        }

        final picture = recorder.endRecording();
        await decodeImageFromList(File(pickedImage.path).readAsBytesSync())
            .then((decodedImage) async => await picture
                .toImage(decodedImage.width, decodedImage.height)
                .then((img) async => await img
                    .toByteData(format: ui.ImageByteFormat.png)
                    .then((value) => setState(() {
                          faceDetectImage = imgData;
                          imgBytes = value!;
                        }))));
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void initState() {
    imagePicker = ImagePicker();
    super.initState();
  }

  void _chooseImageSourceModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndProcess(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndProcess(source: ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Face Detection'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ImagePreview(imagePath: pickedImagePath),
          ),
          ElevatedButton(
            onPressed: _chooseImageSourceModal,
            child: const Text('Pick an image'),
          ),
          const SizedBox(height: 25.0),
          _faceDetectAndBlurImage()
        ],
      ),
    );
  }

  Widget _faceDetectAndBlurImage() {
    return imgBytes != null
        ? Image.memory(Uint8List.view(imgBytes!.buffer),
        width: double.infinity, height: 350.0, fit: BoxFit.contain)
        : Center(
      child: Text("No image selected"),
    );
  }
}
