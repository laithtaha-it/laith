import 'package:equatable/equatable.dart';

sealed class SkillEvent extends Equatable {
  const SkillEvent();

  @override
  List<Object?> get props => const [];
}

final class LoadSkills extends SkillEvent {
  const LoadSkills();
}
