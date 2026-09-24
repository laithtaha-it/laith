import '../../domain/entities/cv_section.dart';
import '../../domain/repositories/cv_repository.dart';
import '../datasources/cv_remote_data_source.dart';

class CvRepositoryImpl implements CvRepository {
  CvRepositoryImpl({CvRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CvRemoteDataSource();

  final CvRemoteDataSource _remoteDataSource;

  @override
  Future<List<CvSection>> getSections() async {
    final documents = await _remoteDataSource.getSections();
    return documents
        .map((document) => CvSection.fromMap(document.id, document.data()))
        .toList();
  }

  @override
  Future<void> saveSection(CvSection section) =>
      _remoteDataSource.saveSection(section.id, section.toMap());

  @override
  Future<void> deleteSection(String id) => _remoteDataSource.deleteSection(id);

  @override
  Future<void> reorderSections(List<CvSection> sections) =>
      _remoteDataSource.reorderSections(sections.map((e) => e.id).toList());
}
