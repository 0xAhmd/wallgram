import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/database/user_service.dart';

class NotificationsServiceInDb {
  final _db = FirebaseFirestore.instance;
  final _auth = AuthService();
  final _userService = UserService();

  Future<void> sendPostNotification(String postId, String message) async {
    try {
      // Get current user's followers
      final currentUserId = _auth.currentUser.uid;
      final followers = await _userService.getFollowersUidsFromFirebase(
        currentUserId,
      );

      final batch = _db.batch();
      final currentUser = await _userService.getUserFromFirebase(currentUserId);

      for (final followerId in followers) {
        // Check if follower blocked the current user
        final blocked =
            await _db
                .collection('users')
                .doc(followerId)
                .collection('blockedUsers')
                .doc(currentUserId)
                .get();

        if (blocked.exists) continue;

        final notificationRef =
            _db
                .collection('notifications')
                .doc(followerId)
                .collection('userNotifications')
                .doc();

        batch.set(notificationRef, {
          'type': 'new_post',
          'senderId': currentUserId,
          'postId': postId,
          'message': 'New post from ${currentUser?.username ?? "a user"}',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      if (followers.isNotEmpty) await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendCommentNotification(String postId, String comment) async {
    try {
      final postDoc = await _db.collection('posts').doc(postId).get();
      if (!postDoc.exists) {
        return;
      }

      final postOwnerId = postDoc['uid'];
      final currentUser = await _userService.getUserFromFirebase(
        _auth.currentUser.uid,
      );
      if (currentUser == null) {
        return;
      }
      await _db
          .collection('notifications')
          .doc(postOwnerId)
          .collection('userNotifications')
          .add({
            'type': 'comment',
            'senderId': currentUser.uid,
            'postId': postId,
            'message':
                '${currentUser.username} commented: ${comment.length > 20 ? comment.substring(0, 20) + '...' : comment}',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
    } catch (e) {}
  }
}
