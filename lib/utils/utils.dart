import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'logger.dart';



class Utils {
  static String handleRequestError(Exception e) {
    if (e is SocketException) {
      logSocketException(e);
      return "No internet connection, please try again";
    } else if (e is TimeoutException) {
      logTimeoutException(e);
      return "Request timed out, please try again";
    } else if (e is FormatException || e is ClientException) {
      logPrint(e);
      return "Something went wrong, please try again";
    } else {
      return e.toString();
    }
  }


  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  String lowerCase(String s) => s[0].toUpperCase() + s.substring(1);

  static Future<void> selectFile(BuildContext context,
      {required Function(File) onSelected}) async {
    FilePickerResult? _file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'jpeg', 'png'],
    );
    if (_file != null) {
      double sizeInMb = _file.files.single.size / (1024 * 1024);
      double sizeInKb = _file.files.single.size / 1024;

      if (sizeInMb > 5) {
        _file = null;
        logPrint("File exceeds 5MB");
        // showErrorBar("File exceeds 5MB");
      } else if (sizeInKb < 128) {
        _file = null;
        logPrint("File size must be greater than 128KB");
        // showErrorBar("File size must be greater than 128KB");
      } else {
        onSelected(File(_file.files.single.path!));
      }
    }
  }

  static void selectImage(BuildContext context,
      {required Function(File) onSelected, ImageSource? imgSource}) {
    final _picker = ImagePicker();

    Future _getImage(ImageSource source) async {
      final pickedFile = await _picker.pickImage(
          source: source, maxHeight: 480, maxWidth: 640, imageQuality: 50);

      if (pickedFile != null) {
        onSelected(File(pickedFile.path));
      }
    }

    if (imgSource != null) {
      _getImage(imgSource);
    } else {
      showDialog(
        context: context,
        useSafeArea: true,
        builder: (BuildContext context) {
          TextTheme textTheme= Theme.of(context).textTheme;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    spreadRadius: 1.0,
                    color: Colors.black54,
                    offset: Offset(5.0, 5.0),
                    blurRadius: 30.0,
                  )
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                alignment: Alignment.center,
                height: 150,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.image),
                      title: Text(
                        "Gallery",
                        style: textTheme.bodyMedium,
                      ),
                      onTap: () {
                        _getImage(ImageSource.gallery);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: Text(
                        "Camera",
                        style: textTheme.bodyMedium,
                      ),
                      onTap: () {
                        _getImage(ImageSource.camera);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
String lowerCase(String s) => s[0].toLowerCase() + s.substring(1);

class ClientException implements Exception {
  final String message;
  final Uri uri;

  ClientException(this.message, this.uri);

  @override
  String toString() => message;
}
