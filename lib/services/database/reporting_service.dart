import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallgram/services/auth/auth_service.dart';

class ReportService {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> reportUserInFirebase(String userId, String postId) async {
    final currentUserId = _auth.currentUser.uid;

    final report = {
      'reportedBy': currentUserId,
      'messageId': postId,
      'messageOwnerID': userId,
      'timestamp:': FieldValue.serverTimestamp(),
    };
    await _db.collection('reports').add(report);
  }
}
