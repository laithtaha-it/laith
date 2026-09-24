import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_featured_projects.dart';
import '../../domain/usecases/get_project_by_id.dart';
import '../../domain/usecases/get_projects.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc({
    required GetProjects getProjects,
    required GetFeaturedProjects getFeaturedProjects,
    required GetProjectById getProjectById,
  }) : _getProjects = getProjects,
       _getFeaturedProjects = getFeaturedProjects,
       _getProjectById = getProjectById,
       super(const ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<LoadFeaturedProjects>(_onLoadFeaturedProjects);
    on<LoadProjectById>(_onLoadProjectById);
    on<PrefetchProjects>(_onPrefetchProjects);
  }

  final GetProjects _getProjects;
  final GetFeaturedProjects _getFeaturedProjects;
  final GetProjectById _getProjectById;

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());

    try {
      final projects = await _getProjects();
      emit(ProjectsLoaded(projects));
    } catch (error) {
      emit(ProjectError(error.toString()));
    }
  }

  Future<void> _onLoadFeaturedProjects(
    LoadFeaturedProjects event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());

    try {
      final projects = await _getFeaturedProjects();
      emit(FeaturedProjectsLoaded(projects));
    } catch (error) {
      emit(ProjectError(error.toString()));
    }
  }

  Future<void> _onLoadProjectById(
    LoadProjectById event,
    Emitter<ProjectState> emit,
  ) async {
    final id = event.id.trim();

    if (id.isEmpty) {
      emit(const ProjectNotFound());
      return;
    }

    emit(const ProjectLoading());

    try {
      final project = await _getProjectById(id);

      if (project == null) {
        emit(const ProjectNotFound());
        return;
      }

      emit(ProjectDetailsLoaded(project));
    } catch (error) {
      emit(ProjectError(error.toString()));
    }
  }

  /// Prefetches the complete published projects list into the
  /// shared repository cache without changing the current UI state.
  Future<void> _onPrefetchProjects(
    PrefetchProjects event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _getProjects();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }
}
