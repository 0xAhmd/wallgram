import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String uid;
  String message;
  String name;
  String username;
  Timestamp timestamp;
  int likes;
  List<String> likedBy;
  Post({
    required this.id,
    required this.uid,
    required this.message,
    required this.name,
    required this.username,
    required this.timestamp,
    required this.likes,
    required this.likedBy,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      id: doc.id,
      uid: doc['uid'],
      message: doc['message'],
      name: doc['name'],
      username: doc['username'],
      timestamp: doc['timestamp'],
      likes: doc['likes'],
      likedBy: List<String>.from(doc['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'message': message,
      'name': name,
      'username': username,
      'timestamp': timestamp,
      'likes': likes,
      'likedBy': likedBy,
    };
  }
}
