import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection("users").doc(uid).set(userData);
  }
}
