// Data base service
// this class handle all the data from and to firebase

// User Profile
// Post Message
// Likes
// Comments
// Account Stuff ( blocks, reports, delete account, )
// follow / unfollow
// search

// ignore_for_file: empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallgram/helper/isTextBomb.dart';
import 'package:wallgram/models/comment.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/services/auth/auth_service.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  final _auth = AuthService();
  final _db = FirebaseFirestore.instance;

  Future<void> saveUserInfoInFirebase({
    required String name,
    required String email,
  }) async {
    String uid = _auth.currentUser.uid;
    String username = email.split('@')[0];

    UserProfile user = UserProfile(
      name: name,
      email: email,
      uid: uid,
      username: username,
      bio: '',
    );
    final userMap = user.toMap();
    await _db.collection('users').doc(uid).set(userMap);
  }

  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection("users").doc(uid).get();

      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserBio(String uid, String bio) async {
    try {
      await _db.collection('users').doc(uid).update({'bio': bio});
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {}
  }

  Future<String> postMessageInFirebase(String message) async {
    try {
      if(isTextBomb(message)){
        return '';
      }
      String uid = _auth.currentUser.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      Post newPost = Post(
        id: '',
        uid: uid,
        message: message,
        name: user!.name,
        username: user.username,
        timestamp: Timestamp.now(),
        likes: 0,
        likedBy: [],
      );

      // Remove 'id' from the map before saving
      Map<String, dynamic> postMap = newPost.toMap();
      // CORRECTED: Single document creation
      DocumentReference docRef = await _db.collection('posts').add(postMap);
      return docRef.id;
      // Firestore generates ID here
    } catch (e) {
      return '';
    }
  }

  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      QuerySnapshot snapshot =
          await _db
              .collection('posts')
              .orderBy('timestamp', descending: true)
              .get();

      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deletPostFromFirebase(String postId) async {
    try {
      await _db.collection('posts').doc(postId).delete();
    } catch (e) {}
  }

  Future<void> toggleLikesInFirebase(String postId) async {
    try {
      String uid = _auth.currentUser.uid;
      DocumentReference postDoc = _db.collection('posts').doc(postId);
      await _db.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);

        List<String> likeBy = List<String>.from(postSnapshot['likedBy'] ?? []);
        int currenLikeCount = postSnapshot['likes'] ?? 0;

        if (!likeBy.contains(uid)) {
          likeBy.add(uid);
          currenLikeCount++;
        } else {
          likeBy.remove(uid);
          currenLikeCount--;
        }

        transaction.update(postDoc, {
          'likes': currenLikeCount,
          'likedBy': likeBy,
        });
      });
    } catch (e) {}
  }

  Future<void> addCommentInFirebase(String postId, String comment) async {
    try {
      String uid = _auth.currentUser.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      Comment newComment = Comment(
        id: '',
        postId: postId,
        uid: uid,
        message: comment,
        name: user!.name,
        username: user.username,
        timestamp: Timestamp.now(),
      ); // new comment
      Map<String, dynamic> commentMap = newComment.toMap();
      await _db.collection('comments').add(commentMap);
    } catch (e) {}
  }

  Future<void> deleteCommentInFirebase(String commentId) async {
    try {
      await _db.collection('comments').doc(commentId).delete();
    } catch (e) {}
  }

  Future<List<Comment>> getCommentsFromFirebase(String postId) async {
    try {
      QuerySnapshot snapshot =
          await _db
              .collection('comments')
              .where('postId', isEqualTo: postId)
              .get();

      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> reportUserInFirebase(String userId, String postId) async {
    final currentUserId = _auth.currentUser.uid;

    final report = {
      'reportedBy': currentUserId,
      'messageId': postId,
      'messageOwnerID': userId,
      'timestamp:': FieldValue.serverTimestamp(),
    };
    await _db.collection('reports').add(report);
  }

  Future<void> blockUserInFirebase(String userId) async {
    final currentUserId = _auth.currentUser.uid;
    //
    await _db
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(userId)
        .set({});
  }

  Future<void> unBlockUserInFirebase(String blockedUserId) async {
    final currentUserId = _auth.currentUser.uid;
    //
    await _db
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(blockedUserId)
        .delete();
  }

  Future<List<String>> getBlockedUsersUidsFromFirebase() async {
    final currentUserId = _auth.currentUser.uid;

    final snapshot =
        await _db
            .collection('users')
            .doc(currentUserId)
            .collection('blockedUsers')
            .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> deleteUserInfoFromFirebase(String uid) async {
    // First, handle all updates (removing likes from posts)
    QuerySnapshot allPosts = await _db.collection('posts').get();
    WriteBatch updateBatch = _db.batch();

    for (QueryDocumentSnapshot post in allPosts.docs) {
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
      var likedBy = postData['likedBy'] as List<dynamic>;
      if (likedBy.contains(uid)) {
        updateBatch.update(post.reference, {
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([uid]),
        });
      }
    }

    // Commit the updates first
    await updateBatch.commit();

    // Then handle all deletions in a separate batch
    WriteBatch deleteBatch = _db.batch();

    // Delete user document
    DocumentReference userDocRef = _db.collection('users').doc(uid);
    deleteBatch.delete(userDocRef);

    // Delete user's posts
    QuerySnapshot userPosts =
        await _db.collection('posts').where('uid', isEqualTo: uid).get();
    for (var post in userPosts.docs) {
      deleteBatch.delete(post.reference);
    }

    // Delete user's comments
    QuerySnapshot userComments =
        await _db.collection('comments').where('uid', isEqualTo: uid).get();
    for (var comment in userComments.docs) {
      deleteBatch.delete(comment.reference);
    }

    // Commit the deletions
    await deleteBatch.commit();
  }

  Future<void> followUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser.uid;

    await _db
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(uid)
        .set({});

    await _db
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(currentUserId)
        .set({});
  }

  Future<void> unflollowUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser.uid;
    await _db
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(uid)
        .delete();

    await _db
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(currentUserId)
        .delete();
  }

  Future<List<String>> getFollowingUidsFromFirebase(String uid) async {
    final snapshot =
        await _db.collection('users').doc(uid).collection('following').get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> getFollowersUidsFromFirebase(String uid) async {
    final snapshot =
        await _db.collection('users').doc(uid).collection('followers').get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<UserProfile>> searchUsersInFirebase(String searchTerm) async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: searchTerm)
            .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
            .get();

    return querySnapshot.docs
        .map((doc) => UserProfile.fromDocument(doc))
        .toList();
  }

  // Updated sendPostNotification
  Future<void> sendPostNotification(String postId, String message) async {
    try {
      // Get current user's followers
      final currentUserId = _auth.currentUser.uid;
      final followers = await getFollowersUidsFromFirebase(currentUserId);

      final batch = _db.batch();
      final currentUser = await getUserFromFirebase(currentUserId);

      for (final followerId in followers) {
        // Check if follower blocked the current user
        final blocked =
            await _db
                .collection('users')
                .doc(followerId)
                .collection('blockedUsers')
                .doc(currentUserId)
                .get();

        if (blocked.exists) continue;

        final notificationRef =
            _db
                .collection('notifications')
                .doc(followerId)
                .collection('userNotifications')
                .doc();

        batch.set(notificationRef, {
          'type': 'new_post',
          'senderId': currentUserId,
          'postId': postId,
          'message': 'New post from ${currentUser?.username ?? "a user"}',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      if (followers.isNotEmpty) await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendCommentNotification(String postId, String comment) async {
    try {
      final postDoc = await _db.collection('posts').doc(postId).get();
      if (!postDoc.exists) {
        return;
      }

      final postOwnerId = postDoc['uid'];
      final currentUser = await getUserFromFirebase(_auth.currentUser.uid);
      if (currentUser == null) {
        return;
      }
      await _db
          .collection('notifications')
          .doc(postOwnerId)
          .collection('userNotifications')
          .add({
            'type': 'comment',
            'senderId': currentUser.uid,
            'postId': postId,
            'message':
                '${currentUser.username} commented: ${comment.length > 20 ? comment.substring(0, 20) + '...' : comment}',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
    } catch (e) {
    }
  }
}
