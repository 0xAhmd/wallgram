import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String uid;
  final Timestamp timestamp;
  final String message;
  final String username;
  final String name;

  Comment({
    required this.id,
    required this.postId,
    required this.uid,
    required this.timestamp,
    required this.message,
    required this.username,
    required this.name,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      id: doc.id,
      postId: doc['postId'],
      uid: doc['uid'],
      timestamp: doc['timestamp'],
      message: doc['message'],
      username: doc['username'],
      name: doc['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'postId': postId,
      'uid': uid,
      'timestamp': timestamp,
      'message': message,
      'username': username,
      'name': name,
    };
  }
}
