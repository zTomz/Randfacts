import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:randfacts/api_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundNotifier extends StateNotifier<File?> {
  BackgroundNotifier() : super(null);

  late SharedPreferences prefInstance;
  late String appDocDirecPath;
  List<String> images = [];
  Color foregroundColor = Colors.white;

  void init() async {
    prefInstance = await SharedPreferences.getInstance();
    appDocDirecPath = await getApplicationDocumentsDirectory().then(
      (value) => value.path,
    );
    // Load all background image files from api
    loadImages();

    // Load background image
    final backgroundData = prefInstance.getString("background");
    if (backgroundData == null || backgroundData == "none") {
      state = null;
      return;
    }

    final imageFile = File("$appDocDirecPath/$backgroundData");
    if (imageFile.existsSync()) {
      state = imageFile;
    } else {
      state = null;
    }
  }

  void changeImage(String newImage) async {
    final imageName = newImage.split("/").last;

    if (!File("$appDocDirecPath/$imageName").existsSync()) {
      await _saveImageFromNetwork(newImage, imageName);
    }

    state = File("$appDocDirecPath/$imageName");
    prefInstance.setString("background", imageName);
  }

  Future<void> _saveImageFromNetwork(String url, String fileName) async {
    final uri = Uri.parse(url);
    final response = await get(uri);

    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;
      File imageFile = File("$appDocDirecPath/$fileName");
      imageFile.createSync();
      imageFile.writeAsBytesSync(imageBytes);
    } else {
      return;
    }
  }

  void deleteAllSavedImages() {
    state = null;
    prefInstance.setString("background", "none");

    final appDocDir = Directory(appDocDirecPath);
    appDocDir.deleteSync();
  }

  void loadImages() async {
    final uri = Uri.parse(
      "https://pixabay.com/api?key=$pixabayApiKey&orientation=vertical&per_page=50&image_type=illustration",
    );

    final response = await get(uri);

    if (response.statusCode == 200) {
      final hits = jsonDecode(response.body)["hits"] as List<dynamic>;

      for (final element in hits) {
        images.add(element["largeImageURL"]);
      }
    }
  }

  void changeBackgroundToLocalImage(PlatformFile platformFile) {
    File fileFromPicker = File(platformFile.path!);
    File newBackgroundImageFile = File("$appDocDirecPath/${platformFile.name}");
    newBackgroundImageFile.createSync();
    newBackgroundImageFile.writeAsBytesSync(fileFromPicker.readAsBytesSync());

    state = File("$appDocDirecPath/${platformFile.name}");
    prefInstance.setString("background", platformFile.name);
  }
}
