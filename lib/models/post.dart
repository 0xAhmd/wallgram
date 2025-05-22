import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'post.g.dart';

@HiveType(typeId: 0)
class Post extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String uid;

  @HiveField(2)
  String message;

  @HiveField(3)
  String name;

  @HiveField(4)
  String username;

  @HiveField(5)
  DateTime timestamp; // ✅ use DateTime instead of Timestamp

  @HiveField(6)
  int likes;

  @HiveField(7)
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
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      uid: data['uid'] ?? '',
      message: data['message'] ?? '',
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(), // ✅ Firebase -> DateTime
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'message': message,
      'name': name,
      'username': username,
      'timestamp': Timestamp.fromDate(timestamp), // ✅ DateTime -> Firebase Timestamp
      'likes': likes,
      'likedBy': likedBy,
    };
  }
}
