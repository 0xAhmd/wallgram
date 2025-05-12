import 'package:flutter/material.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  final _auth = AuthService();
  final _db = DatabaseService();

  Future<UserProfile?> userProfile(String uid) async {
    return _db.getUserFromFirebase(uid);
  }
}
