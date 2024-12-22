import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';

class FirebaseHelper {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadMedia(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }
}
