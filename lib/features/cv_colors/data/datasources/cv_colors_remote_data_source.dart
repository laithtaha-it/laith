import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';

class CvColorsRemoteDataSource {
  CvColorsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>> getColors() async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.cvColors)
        .doc(FirestoreCollections.cvColorsDocument)
        .get();
    return snapshot.data() ?? <String, dynamic>{};
  }

  Future<void> saveColors(Map<String, dynamic> data) => _firestore
      .collection(FirestoreCollections.cvColors)
      .doc(FirestoreCollections.cvColorsDocument)
      .set(data, SetOptions(merge: true));
}
