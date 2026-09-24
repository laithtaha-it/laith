import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../models/project_model.dart';

abstract interface class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getPublishedProjects();

  Future<List<ProjectModel>> getFeaturedProjects();

  Future<ProjectModel?> getProjectById(String id);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  ProjectRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _projects =>
      _firestore.collection(FirestoreCollections.projects);

  @override
  Future<List<ProjectModel>> getPublishedProjects() async {
    final snapshot = await _projects.where('published', isEqualTo: true).get();

    final projects = snapshot.docs
        .map(
          (document) =>
              ProjectModel.fromFirestore(document.id, document.data()),
        )
        .toList(growable: false);

    final sortedProjects = List<ProjectModel>.from(projects)
      ..sort((a, b) => a.order.compareTo(b.order));

    return List<ProjectModel>.unmodifiable(sortedProjects);
  }

  @override
  Future<List<ProjectModel>> getFeaturedProjects() async {
    final snapshot = await _projects
        .where('published', isEqualTo: true)
        .where('featured', isEqualTo: true)
        .where('showOnHome', isEqualTo: true)
        .get();

    final projects = snapshot.docs
        .map(
          (document) =>
              ProjectModel.fromFirestore(document.id, document.data()),
        )
        .toList(growable: false);

    final sortedProjects = List<ProjectModel>.from(projects)
      ..sort((a, b) => a.order.compareTo(b.order));

    return List<ProjectModel>.unmodifiable(sortedProjects.take(3));
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    final document = await _projects.doc(normalizedId).get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    final project = ProjectModel.fromFirestore(document.id, data);

    if (!project.published) {
      return null;
    }

    return project;
  }
}
