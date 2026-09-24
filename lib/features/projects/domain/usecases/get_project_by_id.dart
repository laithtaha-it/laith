import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjectById {
  const GetProjectById(this._repository);

  final ProjectRepository _repository;

  Future<Project?> call(String id) {
    return _repository.getProjectById(id);
  }
}
