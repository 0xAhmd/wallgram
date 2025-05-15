import 'package:flutter/material.dart';
import 'package:wallgram/models/comment.dart';
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
    final blockedUsers = await _db.getBlockedUsersUidsFromFirebase();
    posts = allPosts.where((post) => !blockedUsers.contains(post.uid)).toList();
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

  final Map<String, List<Comment>> _comments = {};

  List<Comment> getComments(String postId) => _comments[postId] ?? [];

  Future<void> loadComments(String postId) async {
    final allComments = await _db.getCommentsFromFirebase(postId);
    _comments[postId] = allComments;
    notifyListeners();
  }

  Future<void> addComment(String postId, String comment) async {
    await _db.addCommentInFirebase(postId, comment);
    await loadComments(postId);
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _db.deleteCommentInFirebase(commentId);
    await loadComments(postId); // ✅ Correct postId now
  }

  List<UserProfile> _blockedUsers = [];
  List<UserProfile> get blockedUsers => _blockedUsers;

  Future<void> loadBlockedUsers() async {
    final blockedUsersIds = await _db.getBlockedUsersUidsFromFirebase();
    final blockedUserData = await Future.wait(
      blockedUsersIds.map((id) => _db.getUserFromFirebase(id)),
    );
    _blockedUsers = blockedUserData.whereType<UserProfile>().toList();
    notifyListeners();
  }

  Future<void> blockUser(String userId) async {
    await _db.blockUserInFirebase(userId);
    await loadBlockedUsers();
    await loadAllPosts();
    notifyListeners();
  }

  Future<void> unBlockUser(String userId) async {
    await _db.unBlockUserInFirebase(userId);
    await loadBlockedUsers();
    await loadAllPosts();
    notifyListeners();
  }

  Future<void> reporUser(String postId, String userId) async {
    await _db.reportUserInFirebase(userId, postId);
  }

  Future<void> deleteUserAccount() async {}
}
