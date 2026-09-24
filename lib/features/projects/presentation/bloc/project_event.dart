import 'package:equatable/equatable.dart';

sealed class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => const [];
}

final class LoadProjects extends ProjectEvent {
  const LoadProjects();
}

final class LoadFeaturedProjects extends ProjectEvent {
  const LoadFeaturedProjects();
}

final class LoadProjectById extends ProjectEvent {
  const LoadProjectById(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Loads the complete published projects list into the shared repository cache
/// without changing the visible ProjectBloc state.
final class PrefetchProjects extends ProjectEvent {
  const PrefetchProjects();
}
