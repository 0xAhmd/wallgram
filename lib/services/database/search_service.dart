import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallgram/models/user_profile_model.dart';

class SearchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<List<UserProfile>> searchUsersInFirebase(String searchTerm) async {
    final querySnapshot =
        await _db
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: searchTerm)
            .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
            .get();

    return querySnapshot.docs
        .map((doc) => UserProfile.fromDocument(doc))
        .toList();
  }
}
