import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wallgram/models/user_profile_model.dart';

class UserService {
  final db = FirebaseFirestore.instance;

  Future<void> saveUserInfoInFirebase({
    required String uid,
    required String name,
    required String email,
    String? imageUrl, // <-- optional image URL
  }) async {
    String username = email.split('@')[0];

    UserProfile user = UserProfile(
      name: name,
      email: email,
      uid: uid,
      username: username,
      bio: '',
      profileImage: imageUrl, // <-- include the image
    );

    final userMap = user.toMap();
    await db.collection('users').doc(uid).set(userMap);
  }

  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await db.collection("users").doc(uid).get();

      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserBio(String uid, String bio) async {
    try {
      await db.collection('users').doc(uid).update({'bio': bio});
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {}
  }

  Future<List<String>> getBlockedUsersUidsFromFirebase(
    String currentUserId,
  ) async {
    final snapshot =
        await db
            .collection('users')
            .doc(currentUserId)
            .collection('blockedUsers')
            .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> blockUserInFirebase(String currentUserId, String userId) async {
     debugPrint('Blocking $userId for user $currentUserId');

    await db
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(userId)
        .set({});

        
  }

  Future<void> unBlockUserInFirebase(
    String currentUserId,
    String blockedUserId,
  ) async {
    await db
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(blockedUserId)
        .delete();
  }

  Future<void> deleteUserInfoFromFirebase(String uid) async {
    // First, handle all updates (removing likes from posts)
    QuerySnapshot allPosts = await db.collection('posts').get();
    WriteBatch updateBatch = db.batch();

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
    WriteBatch deleteBatch = db.batch();

    // Delete user document
    DocumentReference userDocRef = db.collection('users').doc(uid);
    deleteBatch.delete(userDocRef);

    // Delete user's posts
    QuerySnapshot userPosts =
        await db.collection('posts').where('uid', isEqualTo: uid).get();
    for (var post in userPosts.docs) {
      deleteBatch.delete(post.reference);
    }

    // Delete user's comments
    QuerySnapshot userComments =
        await db.collection('comments').where('uid', isEqualTo: uid).get();
    for (var comment in userComments.docs) {
      deleteBatch.delete(comment.reference);
    }

    // Commit the deletions
    await deleteBatch.commit();
  }

  Future<void> followUserInFirebase(String currentUserId, String uid) async {
    await db
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(uid)
        .set({});

    await db
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(currentUserId)
        .set({});
  }

  Future<void> unflollowUserInFirebase(String currentUserId, String uid) async {
    await db
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(uid)
        .delete();

    await db
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(currentUserId)
        .delete();
  }

  Future<List<String>> getFollowingUidsFromFirebase(String uid) async {
    final snapshot =
        await db.collection('users').doc(uid).collection('following').get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> getFollowersUidsFromFirebase(String uid) async {
    final snapshot =
        await db.collection('users').doc(uid).collection('followers').get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
