import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetFeaturedProjects {
  const GetFeaturedProjects(this._repository);

  final ProjectRepository _repository;

  Future<List<Project>> call() {
    return _repository.getFeaturedProjects();
  }
}
