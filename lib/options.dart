import 'package:flutter/material.dart';
import 'package:mldemo/home_screen.dart';

import 'face_detection.dart';


class MLOptions extends StatelessWidget {
  const MLOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: Text("Face detection"),
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => FaceDetectionPage(),));
              },
            ),
            TextButton(
              child: Text("Text recognition"),
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => TextRecognition(),));
              },
            )
          ],
        ),
      ),
    );
  }
}
