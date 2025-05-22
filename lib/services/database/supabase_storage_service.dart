import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupabaseStorageService {
  static final _client = Supabase.instance.client;
  static final _bucket = _client.storage.from('images'); // Your Supabase bucket
  static final _firestore = FirebaseFirestore.instance;

  /// Upload image to Supabase and update Firestore with the image URL
  static Future<String?> uploadImageAndSaveToFirestore({
    required File file,
    required String uid,
  }) async {
    try {
      final fileName = path.basename(file.path);
      final fileBytes = await file.readAsBytes();
      final mimeType = lookupMimeType(file.path);

      // Upload to Supabase
      await _bucket.uploadBinary(
        fileName,
        fileBytes,
        fileOptions: FileOptions(contentType: mimeType),
      );

      final publicUrl = _bucket.getPublicUrl(fileName);

      // Update Firestore
      await _firestore.collection('users').doc(uid).update({
        'profileImage': publicUrl,
      });

      return publicUrl;
    } catch (e) {
      print('Upload or Firestore update failed: $e');
      return null;
    }
  }
}
