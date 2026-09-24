import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>?> getHomeContent();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, dynamic>?> getHomeContent() async {
    final homeFuture = _firestore
        .collection(FirestoreCollections.siteContent)
        .doc('home')
        .get();

    final aboutFuture = _firestore
        .collection(FirestoreCollections.about)
        .doc('main')
        .get();

    final results = await Future.wait([homeFuture, aboutFuture]);

    final homeDocument = results[0];
    final aboutDocument = results[1];

    if (!homeDocument.exists) {
      return null;
    }

    final homeData = homeDocument.data();

    if (homeData == null) {
      return null;
    }

    final aboutData = aboutDocument.data();

    return {...homeData, 'about': aboutData ?? <String, dynamic>{}};
  }
}
