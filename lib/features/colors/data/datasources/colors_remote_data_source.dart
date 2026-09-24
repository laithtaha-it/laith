import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';

class ColorsRemoteDataSource {
  ColorsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>> getColors() async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.colors)
        .doc(FirestoreCollections.colorsDocument)
        .get();

    return snapshot.data() ?? <String, dynamic>{};
  }

  Future<void> saveColors(Map<String, dynamic> data) {
    return _firestore
        .collection(FirestoreCollections.colors)
        .doc(FirestoreCollections.colorsDocument)
        .set(data, SetOptions(merge: true));
  }
}
