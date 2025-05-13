import 'package:flutter/material.dart';
import 'package:wallgram/models/post.dart';
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

  List<Post> posts = [];
  List<Post> get allPosts => posts;

  Future<void> postMessage(String message) async {
    await _db.postMessageInFirebase(message);
    await loadAllPosts();
  }

  Future<void> loadAllPosts() async {
    final allPosts = await _db.getAllPostsFromFirebase();
    posts = allPosts;
    notifyListeners();
  }

  List<Post> userPosts(String uid) =>
      posts.where((post) => post.uid == uid).toList();

  Future<void> deletePostFromFirebase(String postId) async {
    await _db.deletPostFromFirebase(postId);
    await loadAllPosts();
  }
}
