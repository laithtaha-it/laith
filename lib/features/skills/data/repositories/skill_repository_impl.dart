import '../../domain/entities/skill.dart';
import '../../domain/repositories/skill_repository.dart';
import '../datasources/skill_remote_data_source.dart';

class SkillRepositoryImpl implements SkillRepository {
  SkillRepositoryImpl({required SkillRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final SkillRemoteDataSource _remoteDataSource;

  @override
  Future<List<Skill>> getSkills() async {
    final skills = await _remoteDataSource.getSkills();

    skills.sort((a, b) => a.order.compareTo(b.order));

    return skills;
  }
}
