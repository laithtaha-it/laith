import '../entities/cv_section.dart';

abstract class CvRepository {
  Future<List<CvSection>> getSections();
  Future<void> saveSection(CvSection section);
  Future<void> deleteSection(String id);
  Future<void> reorderSections(List<CvSection> sections);
}
