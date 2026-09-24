import '../entities/project.dart';

abstract interface class ProjectRepository {
  Future<List<Project>> getPublishedProjects();

  Future<List<Project>> getFeaturedProjects();

  Future<Project?> getProjectById(String id);
}
