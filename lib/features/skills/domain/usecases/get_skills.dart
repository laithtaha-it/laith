import '../entities/skill.dart';
import '../repositories/skill_repository.dart';

class GetSkills {
  const GetSkills(this._repository);

  final SkillRepository _repository;

  Future<List<Skill>> call() {
    return _repository.getSkills();
  }
}
