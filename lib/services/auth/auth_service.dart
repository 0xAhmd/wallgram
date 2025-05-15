/*
auth service to handle authentication using firebase
- get user
- get uid
- Login 
- Register
- Logout
- Delete Account
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:wallgram/services/database/database_service.dart';

class AuthService {
  // get an instance from current user
  final _auth = FirebaseAuth.instance;
  // get user from firebase
  User get currentUser => _auth.currentUser!;
  String get id => _auth.currentUser!.uid;

  Future<UserCredential> loginService(String email, String password) async {
    try {
      final userCredentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredentials;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
      throw Exception(e.code);
    }
  }

  Future<UserCredential> registerService(String email, String password) async {
    try {
      final userCredentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredentials;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
      throw Exception(e.code);
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  Future<void> deleteUserAccount() async {
    User? user = _auth.currentUser!;
    await DatabaseService().deleteUserInfoFromFirebase(user.uid);
    await user.delete();
  }
}
