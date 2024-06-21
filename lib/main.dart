import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/utils/logger.dart';
import 'package:test_app/utils/utils.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  List<dynamic>? recog;
  bool imageSelect=false;

  @override
  void initState() {
    super.initState();
    logPrint("Models loading intialize");
    loadModel();
    //     .then((val) {
    //   setState(() {
    //     imageSelect = false;
    //   });
    // });
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res = (
          await Tflite.loadModel(
              model: "assets/imageclassifier_quant.tflite",
              labels: "assets/labels.txt"
          ))!;
      logPrint("Models loading status: $res");
    } catch (e) {
      logPrint("Failed to load model: $e");
    }
  }
  Future classifyImage(File image) async {
    try {
      var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults:1,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5,
      );
      if (output != null && output.isNotEmpty) {
        setState(() {
          recog = output;
        });
      } else {
        logPrint("Model output is null or empty.");
      }
    } catch (e) {
      logPrint("Error classifying image: $e");
    }
  }

  // Future<void> predData() async {
  //   final interpreter = await Interpreter.fromAsset('predmodel.tflite');
  //   var input = [
  //     [953.0, 1075.0, 1695.0, 3736.0, 5340.0]
  //   ];
  //   var output = List.filled(1, 0).reshape([1, 1]);
  //   interpreter.run(input, output);
  //   print(output[0][0]);
  //
  //   this.setState(() {
  //     predValue = output[0][0].toString();
  //   });
  // }

  void _incrementCounter() {
    Utils.selectImage(context, onSelected: (file) {
      setState(() {
        _image = file;
        imageSelect=true;
        logPrint("imggg${_image}");
      });
      classifyImage(_image!);
    },imgSource:ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20)),
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 1.5,
                child: _image != null
                    ? Image.file(
                  _image!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : null),
            const SizedBox(
              height: 20,
            ),
            recog != null && recog!.isNotEmpty
                ? Text('Prediction: ${recog![0]['label']}\nConfidence: ${recog![0]['confidence'].toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
              ),
            ):Text('not identified',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
