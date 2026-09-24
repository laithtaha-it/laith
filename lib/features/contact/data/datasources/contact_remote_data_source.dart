import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';

abstract class ContactRemoteDataSource {
  Future<Map<String, dynamic>?> getContactContent();
}

class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  ContactRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, dynamic>?> getContactContent() async {
    final document = await _firestore
        .collection(FirestoreCollections.contact)
        .doc('main')
        .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }
}
