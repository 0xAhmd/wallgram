import 'package:flutter/material.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  // ignore: unused_field
  final _db = DatabaseService();
  final _auth = AuthService();

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
    initializeLikesMap();
    notifyListeners();
  }

  List<Post> userPosts(String uid) =>
      posts.where((post) => post.uid == uid).toList();

  Future<void> deletePostFromFirebase(String postId) async {
    await _db.deletPostFromFirebase(postId);
    await loadAllPosts();
  }

  Map<String, int> likesCount = {};
  Set<String> likes =
      {}; // changed from List<String> to Set<String> for efficiency

  bool isPostLikedByCurrentUser(String postId) {
    return likes.contains(postId);
  }

  int getLikesCount(String postId) {
    return likesCount[postId] ?? 0; // default to 0 if not initialized
  }

  void initializeLikesMap() async {
    likesCount.clear();
    likes.clear();

    final currentUserId = _auth.currentUser.uid;
    for (var post in posts) {
      likesCount[post.id] = post.likes; // ensure default fallback

      if (post.likedBy.contains(currentUserId)) {
        likes.add(post.id);
      }
    }

    notifyListeners();
  }

  Future<void> toggleLikes(String postId) async {
    final likedPostOriginal = Set<String>.from(likes);
    final likesCountOriginal = Map<String, int>.from(likesCount);

    if (likes.contains(postId)) {
      likes.remove(postId);
      likesCount[postId] = (likesCount[postId] ?? 1) - 1;
      if (likesCount[postId]! < 0) likesCount[postId] = 0;
    } else {
      likes.add(postId);
      likesCount[postId] = (likesCount[postId] ?? 0) + 1;
    }

    notifyListeners();

    try {
      await _db.toggleLikesInFirebase(postId);
    } catch (e) {
      // rollback on failure
      likes = likedPostOriginal;
      likesCount = likesCountOriginal;
      notifyListeners();
    }
  }
}
