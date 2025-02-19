import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_regex/flutter_regex.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mldemo/send_aadhaar_details.dart';

import 'image_preview.dart';

class TextRecognition extends StatefulWidget {
  const TextRecognition({super.key});

  @override
  State<TextRecognition> createState() => _TextRecognitionState();
}

class _TextRecognitionState extends State<TextRecognition> {
  late TextRecognizer textRecognizer;
  late ImagePicker imagePicker;

  String? pickedImagePath;
  String recognizedText = "";


  String name = "";
  String uid = "";
  String gender = "";
  String dob = "";
  bool collectingName = false;
  bool nameFound = false;

  bool isRecognizing = false;

  @override
  void initState() {
    super.initState();

    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    imagePicker = ImagePicker();
  }

  void _pickImageAndProcess({required ImageSource source}) async {
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      pickedImagePath = pickedImage.path;
      isRecognizing = true;
    });

    try {
      final inputImage = InputImage.fromFilePath(pickedImage.path);
      final RecognizedText recognisedText =
      await textRecognizer.processImage(inputImage);

      recognizedText = "";

      bool isPossibleName(String text) {

        return text.isNotEmpty &&
            text.length > 1 &&
            text.isDateTimeUTC() == false &&
            RegExp(r'^[A-Z][a-zA-Z\s]*$').hasMatch(text) &&
            text != 'GOVERNMENT OF INDIA' && text != 'Government of India' && text != 'Government of ndia' &&
            !text.toLowerCase().contains('issue date') &&
            !text.toLowerCase().contains('dob') &&
            !text.contains(RegExp('\b(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/[0-9]{4}\b'));
      }



      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {

          recognizedText += "${line.text}\n";


          // Name search
          if (line.text.contains("Name") || RegExp(r'^[A-Z][a-z]+ [A-Z][a-z]+ [A-Z][a-z]+').hasMatch(line.text) && !line.text.contains(RegExp(r'[0-9]'))){
            name = line.text;
            int index = line.text.indexOf("Name");
            int startIndex = index + 4;
            name = line.text.substring(startIndex).trim();
            nameFound = true;

          }



          // Gender Search
          if(line.text.contains("Gender:")){
            int index = line.text.indexOf("Gender:");
            int startIndex = index + 7;
            gender = line.text.substring(startIndex).trim();
          } else if(line.text.toUpperCase().contains("MALE")){
            gender = "Male";
          } else if(line.text.toUpperCase().contains("FEMALE")){
            gender = "Female";
          }

          // DOB search

          if(line.text.contains("DOB")){
            int index = line.text.indexOf("DOB");
            int startIndex = index + 3;
            dob = line.text.substring(startIndex).trim();
          }

          if(line.text.contains("DOB:") || line.text.contains("Year of Birth")){
            int index = line.text.indexOf("DOB:");
            int startIndex = index + 4;
            dob = line.text.substring(startIndex).trim();
          }



          //UID Search
          RegExp aadhaarRegex = RegExp(r"\b\d{4}\s\d{4}\s\d{4}\b");

          for (int i = 0; i < line.text.length; i++) {
            Iterable<Match> matches = aadhaarRegex.allMatches(line.text);
            if(matches.isNotEmpty){
              uid = matches.first.group(0)!;
              uid = uid.replaceRange(uid.length - 4, uid.length, "XXXX");
            }
          }

          RegExp nameRegExp = RegExp(r'\b[A-Z][a-zA-Z]+\s[A-Z][a-zA-Z]+\s[A-Z][a-zA-Z]+\b');

          for (int i = 0; i < line.text.length; i++) {
            Iterable<RegExpMatch> matches = nameRegExp.allMatches(line.text);

            if (matches.isNotEmpty) {
              name = matches.first.group(0)!;
            }
          }
          if (isPossibleName(line.text)) {
            // Start collecting the name if not already started
            if (!collectingName) {
              name = line.text;
              collectingName = true;
              nameFound = true;
            }
          }
          if (nameFound) continue;
        }
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recognizing text: $e'),
        ),
      );
    } finally {
      setState(() {
        isRecognizing = false;
      });
    }
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

  void _copyTextToClipboard() async {
    if (recognizedText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: recognizedText));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard'),
        ),
      );
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SendAadhaarDetails(
        name: name,
        uid: uid,
        dob: dob,
        gender: gender,),));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Text Recognition'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ImagePreview(imagePath: pickedImagePath),
            ),
            ElevatedButton(
              onPressed: isRecognizing ? null : _chooseImageSourceModal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pick an image'),
                  if (isRecognizing) ...[
                    const SizedBox(width: 20),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recognized Text",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 16,
                    ),
                    onPressed: _copyTextToClipboard,
                  ),
                ],
              ),
            ),
            if (!isRecognizing) ...[
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Flexible(
                          child: SelectableText(
                            recognizedText.isEmpty
                                ? "No text recognized"
                                : "UID: $uid\nName: $name\nDOB: $dob\nGender: $gender",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}