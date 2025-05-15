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
import 'package:wallgram/models/comment.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/services/auth/auth_service.dart';

class DatabaseService {
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
    } catch (e) {
    }
  }

  Future<void> postMessageInFirebase(String message) async {
    try {
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
      await _db.collection('posts').add(postMap); // Firestore generates ID here
    } catch (e) {}
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
    WriteBatch batch = _db.batch();
    DocumentReference userDocRef = _db.collection('users').doc(uid);
    batch.delete(userDocRef);
    QuerySnapshot userPosts =
        await _db.collection('posts').where('uid', isEqualTo: uid).get();

    for (var post in userPosts.docs) {
      batch.delete(post.reference);
    }

    QuerySnapshot userComments =
        await _db.collection('comments').where('uid', isEqualTo: uid).get();

    for (var comment in userComments.docs) {
      batch.delete(comment.reference);
    }

    QuerySnapshot allPosts = await _db.collection('posts').get();

    for (QueryDocumentSnapshot post in allPosts.docs) {
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
      var likedBy = postData['likedBy'] as List<dynamic>;
      if (likedBy.contains(uid)) {
        batch.update(post.reference, {
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([uid]),
        });
      }
    }

    await batch.commit();
  }
}
