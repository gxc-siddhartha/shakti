// lib/core/helpers/image_helper.dart
import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class ImageHelper {
  ImageHelper._private();
  static final ImageHelper _instance = ImageHelper._private();
  static ImageHelper get instance => _instance;

  final ImagePicker _picker = ImagePicker();

  Future<String> imageFileToBase64(XFile imageFile) async {
    // Read file as bytes - XFile has its own readAsBytes method
    List<int> imageBytes = await imageFile.readAsBytes();

    // Convert bytes to base64 string
    String base64Image = base64Encode(imageBytes);
    print(base64Image);

    return base64Image;
  }

  // Pick single image from gallery
  Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 50,
    bool requestFullMetadata = true,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        requestFullMetadata: requestFullMetadata,
      );
      return image;
    } catch (e) {
      return null;
    }
  }

  // Pick multiple images from gallery
  Future<List<XFile>?> pickMultiImage({
    int imageQuality = 80,
    bool requestFullMetadata = true,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: imageQuality,
        requestFullMetadata: requestFullMetadata,
      );
      return images;
    } catch (e) {
      return null;
    }
  }

  // Pick video from gallery
  Future<XFile?> pickVideo({
    ImageSource source = ImageSource.gallery,
    Duration? maxDuration,
  }) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );
      return video;
    } catch (e) {
      return null;
    }
  }

  // Handle lost data (for Android)
  Future<LostDataResponse> retrieveLostData() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      return response;
    } catch (e) {
      return LostDataResponse.empty();
    }
  }
}
