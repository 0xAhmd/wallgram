import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wallgram/models/comment.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/cache/caching_service.dart';
import 'package:wallgram/services/database/database_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db;
  final AuthService _auth;
  final CacheService _cacheService = CacheService(); // Add this line


  AppProvider({DatabaseService? db, AuthService? auth})
    : _db = db ?? DatabaseService(),
      _auth = auth ?? AuthService();

  Future<UserProfile?> userProfile(String uid) async {
    try {
      final user = await _db.getUserFromFirebase(uid);
      if (user == null) {
        // If user doesn't exist, create a basic profile
        final authUser = _auth.currentUser;
        if (authUser.uid == uid) {
          return await createUserProfile(
            uid: uid,
            name: authUser.displayName ?? 'New User',
            email: authUser.email ?? '',
            username:
                authUser.email?.split('@').first ??
                'user_${uid.substring(0, 6)}',
          );
        }
      }
      return user;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateBio(String uid, String bio) async {
    await _db.updateUserBio(uid, bio);
    notifyListeners();
  }

  List<Post> posts = [];
  List<Post> get allPosts => posts;
  List<Post> _followingPosts = [];

  List<Post> get followingPosts => _followingPosts;

  Future<void> postMessage(String message) async {
    try {
      final postId = await _db.postMessageInFirebase(message);
      if (postId.isNotEmpty) {
        final u = await _db.getUserFromFirebase(_auth.currentUser.uid);
        if (u != null) {
          await _db.sendPostNotification(postId, 'New post from ${u.username}');
        }
      }
      await loadAllPosts();
    } catch (e) {
      rethrow;
    }
  }

 Future<void> loadAllPosts() async {
  try {
    // Step 1: Load from cache immediately
    posts = _cacheService.getCachedPosts();
Future.microtask(() {
  notifyListeners();
});final cached = await _cacheService.getCachedPosts();
debugPrint('Loaded ${cached.length} posts from cache');

    // Step 2: Load fresh posts from Firebase
    final allPosts = await _db.getAllPostsFromFirebase();
    final blockedUsers = await _db.getBlockedUsersUidsFromFirebase();

    posts = allPosts.where((post) => !blockedUsers.contains(post.uid)).toList();

    // Step 3: Cache the updated posts
    await _cacheService.cachePosts(posts);

    // Step 4: Proceed as normal
    loadFollowingPosts();
    initializeLikesMap();
    notifyListeners();

  } catch (e) {
    debugPrint('Error loading posts: $e');
  }
}

  Future<void> loadFollowingPosts() async {
    try {
      String currentUserId = _auth.currentUser.uid;
      final followingUserIds = await _db.getFollowingUidsFromFirebase(
        currentUserId,
      );

      // Filter posts to only show those from followed users
      _followingPosts =
          posts.where((post) => followingUserIds.contains(post.uid)).toList();

      // Also update the likes information for these posts
      initializeLikesMap();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading following posts: $e');
      rethrow;
    }
  }

  List<Post> userPosts(String uid) =>
      posts.where((post) => post.uid == uid).toList();

  Future<void> deletePostFromFirebase(String postId) async {
    await _db.deletPostFromFirebase(postId);
    await loadAllPosts();
  }

  Map<String, int> likesCount = {};
  Set<String> likes = {};

  bool isPostLikedByCurrentUser(String postId) => likes.contains(postId);

  int getLikesCount(String postId) => likesCount[postId] ?? 0;

  void initializeLikesMap() {
    likesCount.clear();
    likes.clear();

    final currentUserId = _auth.currentUser.uid;
    for (var post in posts) {
      likesCount[post.id] = post.likes;
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
    } else {
      likes.add(postId);
      likesCount[postId] = (likesCount[postId] ?? 0) + 1;
    }

    notifyListeners();

    try {
      await _db.toggleLikesInFirebase(postId);
    } catch (e) {
      // Rollback on failure
      likes = likedPostOriginal;
      likesCount = likesCountOriginal;
      notifyListeners();
      rethrow;
    }
  }

  final Map<String, List<Comment>> _comments = {};

  List<Comment> getComments(String postId) => _comments[postId] ?? [];

  Future<void> loadComments(String postId) async {
    try {
      final allComments = await _db.getCommentsFromFirebase(postId);
      _comments[postId] = allComments;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading comments: $e');
    }
  }

  Future<void> addComment(String postId, String comment) async {
    await _db.addCommentInFirebase(postId, comment);
    await loadComments(postId);
    await _db.sendCommentNotification(postId, comment);
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _db.deleteCommentInFirebase(commentId);
    await loadComments(postId);
  }

  List<UserProfile> _blockedUsers = [];
  List<UserProfile> get blockedUsers => _blockedUsers;

  Future<void> loadBlockedUsers() async {
    try {
      final blockedUsersIds = await _db.getBlockedUsersUidsFromFirebase();
      final blockedUserData = await Future.wait(
        blockedUsersIds.map((id) => _db.getUserFromFirebase(id)),
      );
      _blockedUsers = blockedUserData.whereType<UserProfile>().toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading blocked users: $e');
    }
  }

  Future<void> blockUser(String userId) async {
    await _db.blockUserInFirebase(userId);
    await loadBlockedUsers();
    await loadAllPosts();
  }

  Future<void> unBlockUser(String userId) async {
    await _db.unBlockUserInFirebase(userId);
    await loadBlockedUsers();
    await loadAllPosts();
  }

  Future<void> reporUser(String postId, String userId) async {
    await _db.reportUserInFirebase(userId, postId);
  }

  Future<UserProfile> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String username,
    String bio = '',
  }) async {
    try {
      await _db.firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'username': username,
        'bio': bio,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return UserProfile(
        uid: uid,
        name: name,
        email: email,
        username: username,
        bio: bio,
      );
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  final Map<String, List<String>> _followers = {};

  final Map<String, List<String>> _following = {};
  final Map<String, int> _followerCount = {};
  final Map<String, int> _followingCount = {};

  int getFollowerCount(String uid) => _followerCount[uid] ?? 0;
  int getFollowingCount(String uid) => _followingCount[uid] ?? 0;

  // load

  Future<void> loadUserFollowers(String uid) async {
    final listOfFollowerUids = await _db.getFollowersUidsFromFirebase(uid);

    _followers[uid] = listOfFollowerUids;
    _followerCount[uid] = listOfFollowerUids.length;

    notifyListeners();
  }

  Future<void> loadUserFollowing(String uid) async {
    final listOfFollowingrUids = await _db.getFollowingUidsFromFirebase(uid);

    _following[uid] = listOfFollowingrUids;
    _followingCount[uid] = listOfFollowingrUids.length;

    notifyListeners();
  }

  Future<void> followUser(String targetUserId) async {
    final currentUserId = _auth.currentUser.uid;
    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUserId, () => []);

    if (!_followers[targetUserId]!.contains(currentUserId)) {
      _followers[targetUserId]?.add(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;
      _following[currentUserId]?.add(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;

      notifyListeners();

      try {
        await _db.followUserInFirebase(targetUserId);
        await loadUserFollowers(currentUserId);
        await loadUserFollowing(currentUserId);
        await loadFollowingPosts(); 
      } catch (e) {
        _followers[targetUserId]?.remove(currentUserId);
        _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) - 1;
        _following[currentUserId]?.remove(targetUserId);
        _followingCount[currentUserId] =
            (_followingCount[currentUserId] ?? 0) - 1;
        notifyListeners();
      }
    }
  }

  Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = _auth.currentUser.uid;
    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUserId, () => []);

    if (_followers[targetUserId]!.contains(currentUserId)) {
      _followers[targetUserId]?.remove(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 1) - 1;
      _following[currentUserId]?.remove(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 1) - 1;
    }

    notifyListeners();

    try {
      await _db.unflollowUserInFirebase(targetUserId);
      await loadUserFollowers(currentUserId);
      await loadUserFollowing(currentUserId);
      await loadFollowingPosts(); // Add this line to refresh following posts
    } catch (e) {
      _followers[targetUserId]?.add(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;
      _following[currentUserId]?.add(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;
      notifyListeners();
    }
  }

  bool isFollowing(String uid) {
    final currentUserId = _auth.currentUser.uid;
    return _followers[uid]?.contains(currentUserId) ?? false;
  }

  final Map<String, List<UserProfile>> _followersProfiles = {};
  final Map<String, List<UserProfile>> _followingProfiles = {};

  List<UserProfile> getListOfFollowerProfile(String uid) {
    return _followersProfiles[uid] ?? [];
  }

  List<UserProfile> getListOfFollowingProfile(String uid) {
    return _followingProfiles[uid] ?? [];
  }

  Future<void> loadUserFollowersProfile(String uid) async {
    try {
      final followerUids = await _db.getFollowersUidsFromFirebase(uid);
      List<UserProfile> followerProfiles = [];
      for (String followerId in followerUids) {
        UserProfile? followerProfile = await _db.getUserFromFirebase(
          followerId,
        );

        if (followerProfile != null) {
          followerProfiles.add(followerProfile);
        }
      }
      _followersProfiles[uid] = followerProfiles;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading followers profile: $e');
    }
  }

  Future<void> loadUserFollowingProfile(String uid) async {
    try {
      final followingIds = await _db.getFollowingUidsFromFirebase(uid);
      List<UserProfile> followingProfiles = [];
      for (String followingId in followingIds) {
        UserProfile? followingProfile = await _db.getUserFromFirebase(
          followingId,
        );

        if (followingProfile != null) {
          followingProfiles.add(followingProfile);
        }
      }
      _followingProfiles[uid] = followingProfiles;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading followers profile: $e');
    }
  }

  List<UserProfile> _searchResult = [];
  List<UserProfile> get searchResult => _searchResult;
bool isSearching = false;

  Future<void> searchUsers(String searchTerm) async {
      isSearching = true;
  notifyListeners();
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final results =
          querySnapshot.docs
              .map((doc) => UserProfile.fromDocument(doc))
              .where(
                (user) =>
                    user.name.toLowerCase().contains(searchTerm.toLowerCase()),
              )
              .toList();

      _searchResult = results;
        isSearching = false;

      notifyListeners();
    } catch (e) {
      debugPrint('Error searching users: $e');
    }
  }

  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  void initNotificationsListener() {
    // Cancel existing subscription to avoid duplicates
    _notificationSubscription?.cancel();

    final userId = _auth.currentUser.uid;
    _notificationSubscription = _db.firestore
        .collection('notifications')
        .doc(userId)
        .collection('userNotifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          _notifications =
              snapshot.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList();
          notifyListeners();
        }, onError: (error) {});
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n['read'] = true;
    }
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.firestore
          .collection('notifications')
          .doc(_auth.currentUser.uid)
          .collection('userNotifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
