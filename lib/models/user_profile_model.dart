import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String name;
  String email;
  String uid;
  String bio;
  String username;
  UserProfile({
    required this.name,
    required this.email,
    required this.uid,
    required this.bio,
    required this.username,
  });
  // firebase -> app {get user profile data from firebase}
  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    // ignore: unused_local_variable
    final data = doc.data() as Map<String, dynamic>;
    // print('Document data: $data');
    return UserProfile(
      name: doc['name'],
      email: doc['email'],
      uid: doc.id,
      bio: doc['bio'],
      username: doc['username'],
    );
  }

  // app -> firebase {save user data into firebase}

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'bio': bio,
      'username': username,
    };
  }
}
