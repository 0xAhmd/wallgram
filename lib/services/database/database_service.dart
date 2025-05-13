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
      // print(e.toString());
      return null;
    }
  }

  Future<void> updateUserBio(String uid, String bio) async {
    try {
      // print('Updating bio for uid: $uid');
      // print('New bio: $bio');

      // Firestore update
      await _db.collection('users').doc(uid).update({'bio': bio});
      // print('Waiting for Firestore to update...');
      await Future.delayed(Duration(seconds: 1));
      // print('Bio updated successfully');
    } catch (e) {
      // print('Error updating bio: $e');
    }
  }

  Future<void> postMessageInFirebase(String message) async {
    try {
      String uid = _auth.currentUser.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      Post newPost = Post(
        id: '', // Leave empty (not used)
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
    } catch (e) {
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
    } catch (e) {
    }
  }
}
