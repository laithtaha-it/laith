import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_skills.dart';
import 'skill_event.dart';
import 'skill_state.dart';

class SkillBloc extends Bloc<SkillEvent, SkillState> {
  SkillBloc({required GetSkills getSkills})
    : _getSkills = getSkills,
      super(const SkillInitial()) {
    on<LoadSkills>(_onLoadSkills);
  }

  final GetSkills _getSkills;

  Future<void> _onLoadSkills(LoadSkills event, Emitter<SkillState> emit) async {
    if (state is SkillLoading || state is SkillsLoaded) {
      return;
    }

    emit(const SkillLoading());

    try {
      final skills = await _getSkills();

      if (skills.isEmpty) {
        emit(const SkillsEmpty());
        return;
      }

      emit(SkillsLoaded(skills));
    } catch (error) {
      emit(SkillError(error.toString()));
    }
  }
}
