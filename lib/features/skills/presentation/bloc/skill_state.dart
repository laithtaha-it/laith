import 'package:equatable/equatable.dart';

import '../../domain/entities/skill.dart';

sealed class SkillState extends Equatable {
  const SkillState();

  @override
  List<Object?> get props => const [];
}

final class SkillInitial extends SkillState {
  const SkillInitial();
}

final class SkillLoading extends SkillState {
  const SkillLoading();
}

final class SkillsLoaded extends SkillState {
  const SkillsLoaded(this.skills);

  final List<Skill> skills;

  @override
  List<Object?> get props => [skills];
}

final class SkillsEmpty extends SkillState {
  const SkillsEmpty();
}

final class SkillError extends SkillState {
  const SkillError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
