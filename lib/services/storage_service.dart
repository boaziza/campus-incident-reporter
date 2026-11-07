import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class UploadResult {
  final String url;
  final String path;

  UploadResult({required this.url, required this.path});
}

class StorageService {
  StorageService._privateConstructor();

  static final StorageService instance = StorageService._privateConstructor();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Photos are stored under incident_images/{uid}/ so the storage rules
  // can check that students only write into their own folder.
  Future<UploadResult> uploadIncidentImage({
    required File file,
    required String uid,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'incident_images/$uid/$fileName';
    final ref = _storage.ref(path);

    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    return UploadResult(url: url, path: path);
  }

  Future<void> deleteImage(String path) async {
    try {
      await _storage.ref(path).delete();
    } on FirebaseException catch (e) {
      // If the photo is already gone we can still delete the report
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
