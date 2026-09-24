import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl({required ProjectRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ProjectRemoteDataSource _remoteDataSource;

  List<Project>? _publishedProjectsCache;
  Future<List<Project>>? _publishedProjectsFuture;

  @override
  Future<List<Project>> getPublishedProjects() {
    final cached = _publishedProjectsCache;

    if (cached != null) {
      return Future.value(cached);
    }

    final existingRequest = _publishedProjectsFuture;

    if (existingRequest != null) {
      return existingRequest;
    }

    final request = _loadPublishedProjects();

    _publishedProjectsFuture = request;

    return request;
  }

  Future<List<Project>> _loadPublishedProjects() async {
    try {
      final projects = await _remoteDataSource.getPublishedProjects();

      _publishedProjectsCache = List<Project>.unmodifiable(projects);

      return _publishedProjectsCache!;
    } finally {
      _publishedProjectsFuture = null;
    }
  }

  @override
  Future<List<Project>> getFeaturedProjects() {
    return _remoteDataSource.getFeaturedProjects();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    final cachedProjects = _publishedProjectsCache;

    if (cachedProjects != null) {
      for (final project in cachedProjects) {
        if (project.id == normalizedId) {
          return project;
        }
      }

      return null;
    }

    return _remoteDataSource.getProjectById(normalizedId);
  }
}
