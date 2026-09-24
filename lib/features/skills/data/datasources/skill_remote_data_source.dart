import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../models/skill_model.dart';

abstract interface class SkillRemoteDataSource {
  Future<List<SkillModel>> getSkills();
}

class SkillRemoteDataSourceImpl implements SkillRemoteDataSource {
  SkillRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<SkillModel>> getSkills() async {
    final results = await Future.wait([
      _firestore.collection(FirestoreCollections.skills).get(),
      _firestore.collection(FirestoreCollections.skillCategories).get(),
    ]);

    final skillsSnapshot = results[0];
    final categoriesSnapshot = results[1];
    final categories = <String, Map<String, dynamic>>{
      for (final doc in categoriesSnapshot.docs) doc.id: doc.data(),
    };

    return skillsSnapshot.docs
        .map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          final categoryId = data['categoryId']?.toString() ?? '';
          final category = categories[categoryId];
          if (category != null) data['category'] = category['name'];
          return SkillModel.fromMap(doc.id, data);
        })
        .where((skill) => skill.nameAr.isNotEmpty || skill.nameEn.isNotEmpty)
        .toList();
  }
}
