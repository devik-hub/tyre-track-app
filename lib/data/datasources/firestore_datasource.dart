import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addDocument(String collection, String id, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(id).set(data);
  }

  Future<void> updateDocument(String collection, String id, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(id).update(data);
  }

  Future<void> deleteDocument(String collection, String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  Future<DocumentSnapshot> getDocument(String collection, String id) async {
    return await _firestore.collection(collection).doc(id).get();
  }

  Future<QuerySnapshot> getCollection(String collection) async {
    return await _firestore.collection(collection).get();
  }
}
