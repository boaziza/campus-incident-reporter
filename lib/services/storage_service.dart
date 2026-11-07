import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class UploadResult {
  final String url;
  final String path; // Cloudinary public_id

  UploadResult({required this.url, required this.path});
}

class ImageUploadException implements Exception {
  final String details;

  ImageUploadException(this.details);

  @override
  String toString() => 'ImageUploadException: $details';
}

// Uploads incident photos to Cloudinary (free tier) instead of
// Firebase Storage, which now requires the paid Blaze plan.
// Only the returned image URL is saved in Firestore.
class StorageService {
  StorageService._privateConstructor();

  static final StorageService instance = StorageService._privateConstructor();

  static String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload';

  Future<UploadResult> uploadIncidentImage({
    required File file,
    required String uid,
  }) async {
    // Unsigned upload: the preset (set to "Unsigned" in the Cloudinary
    // console) allows uploads without putting an API secret in the app.
    final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl))
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = '${CloudinaryConfig.folder}/$uid'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response =
        await http.Response.fromStream(await request.send()).timeout(
      const Duration(seconds: 60),
    );

    if (response.statusCode != 200) {
      throw ImageUploadException(
          'Cloudinary returned ${response.statusCode}: ${response.body}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return UploadResult(
      url: data['secure_url'] as String,
      path: data['public_id'] as String,
    );
  }
}
