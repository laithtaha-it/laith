import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';

class CvRemoteDataSource {
  CvRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sections =>
      _firestore.collection(FirestoreCollections.cvSections);

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getSections() async {
    final snapshot = await _sections.orderBy('order').get();
    return snapshot.docs;
  }

  Future<void> saveSection(String id, Map<String, dynamic> data) =>
      _sections.doc(id).set(data, SetOptions(merge: true));

  Future<void> deleteSection(String id) => _sections.doc(id).delete();

  Future<void> reorderSections(List<String> ids) async {
    final batch = _firestore.batch();
    for (var index = 0; index < ids.length; index++) {
      batch.update(_sections.doc(ids[index]), {'order': index});
    }
    await batch.commit();
  }
}
