import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wallgram/locator.dart';
import 'package:wallgram/services/database/user_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _userService = locator<UserService>();

  User get currentUser => _auth.currentUser!;
  String get id => _auth.currentUser!.uid;

  Future<UserCredential> loginService(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  Future<UserCredential> registerService(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Weak password.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email already in use.');
      }
      throw Exception(e.message ?? 'Unknown error');
    }
  }

  Future<void> logoutUser() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Future<void> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _userService.deleteUserInfoFromFirebase(user.uid);
      await user.delete();
    }
  }

  Future<User?> handleGoogleSignIn() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      final docRef = locator<UserService>().db
          .collection('users')
          .doc(firebaseUser.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        final username =
            firebaseUser.displayName?.toLowerCase().replaceAll(' ', '_') ??
            firebaseUser.email?.split('@').first ??
            'user_${firebaseUser.uid.substring(0, 6)}';

        await docRef.set({
          'name': firebaseUser.displayName ?? 'New User',
          'username': username,
          'email': firebaseUser.email ?? '',
          'bio': '',
          'createdAt': FieldValue.serverTimestamp(),
          'email_verified_manually': false,
        });
      }

      return firebaseUser;
    }

    return null;
  }

  // Example usage for UserService methods that need currentUserId:
  Future<void> saveUserInfo(String name, String email) async {
    await _userService.saveUserInfoInFirebase(
      uid: currentUser.uid,
      name: name,
      email: email,
    );
  }

  Future<void> blockUser(String userId) async {
    await _userService.blockUserInFirebase(currentUser.uid, userId);
  }

  // similarly for other methods...
}
