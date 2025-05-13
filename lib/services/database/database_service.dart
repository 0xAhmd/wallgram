// Data base service
// this class handle all the data from and to firebase

// User Profile
// Post Message
// Likes
// Comments
// Account Stuff ( blocks, reports, delete account, )
// follow / unfollow
// search

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
        id: '',
        uid: uid,
        message: message,
        name: user!.name,
        username: user.username,
        timestamp: Timestamp.now(),
        likes: 0,
        likedBy: [],
      );

      Map<String, dynamic> postMap = newPost.toMap(); // <String, dynamic>
      await _db.collection('posts').add(postMap);
    } catch (e) {
      print(e);
    }
  }
}
