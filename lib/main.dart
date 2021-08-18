import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark, primaryColor: Colors.redAccent),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool loading = false;
  File? _image;
  List<dynamic>? predictions = [];
  @override
  initState() {
    super.initState();
    loadModel();
  }

  dispose() {
    super.dispose();
  }

  detectMask(File? image) async {
    List<dynamic>? prediction = await Tflite.runModelOnImage(
        path: image!.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      predictions = prediction;
      print(predictions);
      loading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/models/model_unquant.tflite",
        labels: "assets/models/labels.txt",
        isAsset: true);
  }

  openCamera() async {
    loading = true;

    PickedFile? pickedFile = (await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 0));
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      detectMask(_image);
    }
  }

  openGallery() async {
    setState(() {
      loading = true;
    });
    PickedFile? pickedFile = (await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 0));
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      detectMask(_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mask TFLite",
          style: GoogleFonts.roboto(fontSize: 20),
        ),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                openCamera();
              },
              child: Container(
                width: size.width,
                padding: EdgeInsets.all(10),
                color: Colors.redAccent,
                child: Text(
                  "Open camera",
                  style: GoogleFonts.roboto(fontSize: 20),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                openGallery();
              },
              child: Container(
                width: size.width,
                padding: EdgeInsets.all(10),
                color: Colors.redAccent,
                child: Text(
                  "Open gallery",
                  style: GoogleFonts.roboto(fontSize: 20),
                ),
              ),
            ),
            loading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  )
                : _image == null
                    ? Container()
                    : Column(
                        children: [
                          Container(
                              height: 200,
                              width: 200,
                              child: Image.file(_image!)),
                          Text(
                              predictions![0]['label'].toString().substring(2)),
                          Text(predictions![0]['confidence']
                                  .toString()
                                  .substring(0, 5) +
                              "%"),
                          // Text(predictions!.length.toString())
                        ],
                      )
          ],
        ),
      ),
    );
  }
}
