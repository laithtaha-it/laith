import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjects {
  const GetProjects(this._repository);

  final ProjectRepository _repository;

  Future<List<Project>> call() {
    return _repository.getPublishedProjects();
  }
}
