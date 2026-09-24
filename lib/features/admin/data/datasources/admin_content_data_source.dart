import 'package:cloud_firestore/cloud_firestore.dart';

class AdminContentDataSource {
  AdminContentDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> collection(String name) =>
      _firestore.collection(name);

  Future<Map<String, dynamic>> getDocument(
    String collection,
    String id,
  ) async {
    final snap = await _firestore.collection(collection).doc(id).get();
    return snap.data() ?? <String, dynamic>{};
  }

  Future<void> setDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) => _firestore
      .collection(collection)
      .doc(id)
      .set(data, SetOptions(merge: true));

  Future<void> deleteDocument(String collection, String id) =>
      _firestore.collection(collection).doc(id).delete();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getCollection(
    String collection,
  ) async {
    final snap = await _firestore.collection(collection).get();
    return snap.docs;
  }
}
