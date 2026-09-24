import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/admin_content_data_source.dart';

class AdminContentRepository {
  AdminContentRepository({AdminContentDataSource? dataSource})
      : _dataSource = dataSource ?? AdminContentDataSource();

  final AdminContentDataSource _dataSource;

  Future<Map<String, dynamic>> getDocument(String collection, String id) =>
      _dataSource.getDocument(collection, id);

  Future<void> saveDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) => _dataSource.setDocument(collection, id, data);

  Future<void> deleteDocument(String collection, String id) =>
      _dataSource.deleteDocument(collection, id);

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getCollection(
    String collection,
  ) => _dataSource.getCollection(collection);
}
