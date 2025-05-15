import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wallgram/services/database/database_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  User get currentUser => _auth.currentUser!;
  String get id => _auth.currentUser!.uid;

  Future<UserCredential> loginService(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password.');
      }
      throw Exception(e.message ?? 'Unknown error');
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
    await _auth.signOut();
  }

  Future<void> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await DatabaseService().deleteUserInfoFromFirebase(user.uid);
      await user.delete();
    }
  }

  // Sign in with Google and ensure Firestore profile exists
  Future<User?> handleGoogleSignIn() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    final firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        // Generate a username from email if display name is not available
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
        });
      }

      return firebaseUser;
    }

    return null;
  }
}
