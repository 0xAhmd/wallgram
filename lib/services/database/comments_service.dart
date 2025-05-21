import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallgram/models/comment.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/database/user_service.dart';

class CommentService {
  UserService _userService = UserService();
  AuthService _auth = AuthService();
  FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<void> addCommentInFirebase(String postId, String comment) async {
    try {
      String uid = _auth.currentUser.uid;
      UserProfile? user = await _userService.getUserFromFirebase(uid);

      Comment newComment = Comment(
        id: '',
        postId: postId,
        uid: uid,
        message: comment,
        name: user!.name,
        username: user.username,
        timestamp: Timestamp.now(),
      ); // new comment
      Map<String, dynamic> commentMap = newComment.toMap();
      await _db.collection('comments').add(commentMap);
    } catch (e) {}
  }

  Future<void> deleteCommentInFirebase(String commentId) async {
    try {
      await _db.collection('comments').doc(commentId).delete();
    } catch (e) {}
  }

  Future<List<Comment>> getCommentsFromFirebase(String postId) async {
    try {
      QuerySnapshot snapshot =
          await _db
              .collection('comments')
              .where('postId', isEqualTo: postId)
              .get();

      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }
}
