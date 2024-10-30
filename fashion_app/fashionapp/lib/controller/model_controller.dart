import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ColorRecommendationProvider with ChangeNotifier {
  XFile? image;
  Map<String, dynamic>? colorRecommendation;
  bool isLoading = false;

  Future<void> optionPickImage(BuildContext context) async {
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text('Pick an Image')),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final image = await ImagePicker().pickImage(source: ImageSource.camera);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(image);
              },
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () async {
                final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(image);
              },
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );

    if (pickedFile != null) {
      image = pickedFile;
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = pickedFile;
      notifyListeners();
    }
  }
  Future<void> pickImageCamera() async {
    try {
      final pickerCamera = ImagePicker();
      final pickedFile = await pickerCamera.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
          image = pickedFile;
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error picking image from camera: $e");
    }
  }

  Future<void> submitImage() async {
    if (image != null) {
      isLoading = true;
      notifyListeners();
      final uri = Uri.parse('https://fashionapp.loca.lt/process-image');
      var request = http.MultipartRequest('POST', uri);
      request.files
          .add(await http.MultipartFile.fromPath('image', image!.path));
      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          final res = await http.Response.fromStream(response);
          colorRecommendation = jsonDecode(res.body);
        } else {
          // ignore: avoid_print
          print('Failed to load recommendations');
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error occurred: $e');
      }
      isLoading = false;
      notifyListeners();
    }
  }
  void resetData() {
    image = null;
    colorRecommendation = null;
    notifyListeners(); 
  }
}
