import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallgram/helper/isTextBomb.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/database/user_service.dart';

class PostService{
  final _db = FirebaseFirestore.instance;
  final _auth = AuthService();
  final _userService = UserService();
  
    Future<String> postMessageInFirebase(String message) async {
    try {
      if (isTextBomb(message)) {
        return '';
      }

      String uid = _auth.currentUser.uid;

      // ➊ — Last-post cooldown check (unchanged) …
      final lastPostDoc =
          await _db
              .collection('users')
              .doc(uid)
              .collection('meta')
              .doc('postInfo')
              .get();
      if (lastPostDoc.exists) {
        final lastTs = lastPostDoc.get('lastPostTimestamp') as Timestamp;
        final diff = DateTime.now().difference(lastTs.toDate()).inSeconds;
        if (diff < 12) {
          throw Exception(
            'Please wait ${12 - diff} seconds before posting again.',
          );
        }
      }

      // ➋ — Fetch user profile and guard null
      UserProfile? user = await _userService.getUserFromFirebase(uid);
      if (user == null) {
        throw Exception('Unable to post: user profile not found.');
      }

      // ➌ — Build and save the post
      Post newPost = Post(
        id: '',
        uid: uid,
        message: message,
        name: user.name,
        username: user.username,
        timestamp: DateTime.now(),
        likes: 0,
        likedBy: [],
      );
      final docRef = await _db.collection('posts').add(newPost.toMap());

      // ➍ — Update last-post timestamp
      await _db
          .collection('users')
          .doc(uid)
          .collection('meta')
          .doc('postInfo')
          .set({'lastPostTimestamp': Timestamp.now()});

      return docRef.id;
    } catch (e) {
      // Let UI handle it
      rethrow;
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
    } catch (e) {}
  }

  Future<void> toggleLikesInFirebase(String postId) async {
    try {
      String uid = _auth.currentUser.uid;
      DocumentReference postDoc = _db.collection('posts').doc(postId);
      await _db.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);

        List<String> likeBy = List<String>.from(postSnapshot['likedBy'] ?? []);
        int currenLikeCount = postSnapshot['likes'] ?? 0;

        if (!likeBy.contains(uid)) {
          likeBy.add(uid);
          currenLikeCount++;
        } else {
          likeBy.remove(uid);
          currenLikeCount--;
        }

        transaction.update(postDoc, {
          'likes': currenLikeCount,
          'likedBy': likeBy,
        });
      });
    } catch (e) {}
  }
  }