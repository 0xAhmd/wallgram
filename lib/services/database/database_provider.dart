import 'package:flutter/material.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  // ignore: unused_field
  final _db = DatabaseService();

  Future<UserProfile?> userProfile(String uid) async {
    return _db.getUserFromFirebase(uid);
  }

  Future<void> updateBio(String uid, String bio) async {
    await _db.updateUserBio(uid, bio);
  }
}
