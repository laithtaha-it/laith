import 'package:equatable/equatable.dart';

import '../../domain/entities/project.dart';

sealed class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => const [];
}

final class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

final class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

final class ProjectsLoaded extends ProjectState {
  const ProjectsLoaded(this.projects);

  final List<Project> projects;

  @override
  List<Object?> get props => [projects];
}

final class FeaturedProjectsLoaded extends ProjectState {
  const FeaturedProjectsLoaded(this.projects);

  final List<Project> projects;

  @override
  List<Object?> get props => [projects];
}

final class ProjectDetailsLoaded extends ProjectState {
  const ProjectDetailsLoaded(this.project);

  final Project project;

  @override
  List<Object?> get props => [project];
}

final class ProjectNotFound extends ProjectState {
  const ProjectNotFound();
}

final class ProjectError extends ProjectState {
  const ProjectError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
