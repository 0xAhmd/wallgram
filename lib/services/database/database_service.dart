import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wallgram/models/comment.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/services/database/comments_service.dart';
import 'package:wallgram/services/database/post_service.dart';
import 'package:wallgram/services/database/reporting_service.dart';
import 'package:wallgram/services/database/search_service.dart';
import 'package:wallgram/services/database/user_service.dart';
import 'package:wallgram/services/database/notification_service.dart';

class DatabaseService {
  final _userService = UserService();
  final _postService = PostService();
  final _commentService = CommentService();
  final _notificationService = NotificationsServiceInDb();
  final _reportService = ReportService();
  final _searchService = SearchService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Post Methods
  Future<String> postMessageInFirebase(String message) {
    return _postService.postMessageInFirebase(message);
  }

  Future<List<Post>> getAllPostsFromFirebase() {
    return _postService.getAllPostsFromFirebase();
  }

  Future<void> deletPostFromFirebase(String postId) {
    return _postService.deletPostFromFirebase(postId);
  }

  Future<void> toggleLikesInFirebase(String postId) {
    return _postService.toggleLikesInFirebase(postId);
  }

  // 🔹 User Methods
  Future<UserProfile?> getUserFromFirebase(String uid) {
    return _userService.getUserFromFirebase(uid);
  }

  Future<void> updateUserBio(String uid, String bio) {
    return _userService.updateUserBio(uid, bio);
  }

  Future<List<String>> getBlockedUsersUidsFromFirebase() {
    return _userService.getBlockedUsersUidsFromFirebase(_auth.currentUser!.uid);
  }

  Future<void> blockUserInFirebase(String userId) {
    return _userService.blockUserInFirebase(userId, _auth.currentUser!.uid);
  }

  Future<void> unBlockUserInFirebase(String userId) {
    return _userService.unBlockUserInFirebase(userId, _auth.currentUser!.uid);
  }

  Future<void> followUserInFirebase(String uid) {
    return _userService.followUserInFirebase(
      _auth.currentUser!.uid,
      uid,
    ); // ✅ Correct order
  }

  Future<void> unflollowUserInFirebase(String uid) {
    return _userService.unflollowUserInFirebase(
      _auth.currentUser!.uid,
      uid,
    ); // ✅ Correct order
  }

  Future<List<String>> getFollowersUidsFromFirebase(String uid) {
    return _userService.getFollowersUidsFromFirebase(uid);
  }

  Future<List<String>> getFollowingUidsFromFirebase(String uid) {
    return _userService.getFollowingUidsFromFirebase(uid);
  }

  // 🔹 Comment Methods
  Future<void> addCommentInFirebase(String postId, String comment) {
    return _commentService.addCommentInFirebase(postId, comment);
  }

  Future<List<Comment>> getCommentsFromFirebase(String postId) {
    return _commentService.getCommentsFromFirebase(postId);
  }

  Future<void> deleteCommentInFirebase(String commentId) {
    return _commentService.deleteCommentInFirebase(commentId);
  }

  // 🔹 Notification Methods
  Future<void> sendPostNotification(String postId, String message) {
    return _notificationService.sendPostNotification(postId, message);
  }

  Future<void> sendCommentNotification(String postId, String comment) {
    return _notificationService.sendCommentNotification(postId, comment);
  }

  // 🔹 Report Methods
  Future<void> reportUserInFirebase(String userId, String postId) {
    return _reportService.reportUserInFirebase(userId, postId);
  }

  // 🔹 Search Methods
  Future<List<UserProfile>> searchUsers(String term) {
    return _searchService.searchUsersInFirebase(term);
  }

  // 🔹 Firebase instance access
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
