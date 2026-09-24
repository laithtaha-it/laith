import '../entities/skill.dart';

abstract interface class SkillRepository {
  Future<List<Skill>> getSkills();
}
