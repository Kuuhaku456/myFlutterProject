import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ColorRecommendationProvider with ChangeNotifier {
  XFile? image;
  Map<String, dynamic>? colorRecommendation;
  bool isLoading = false;
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = pickedFile;
      notifyListeners();
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
          print('Failed to load recommendations');
        }
      } catch (e) {
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
