import '../../domain/entities/app_color_settings.dart';
import '../../domain/repositories/colors_repository.dart';
import '../datasources/colors_remote_data_source.dart';

class ColorsRepositoryImpl implements ColorsRepository {
  ColorsRepositoryImpl({required ColorsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ColorsRemoteDataSource _remoteDataSource;

  @override
  Future<AppColorSettings> getColors() async {
    final data = await _remoteDataSource.getColors();
    if (data.isEmpty) return AppColorSettings.defaults;
    return AppColorSettings.fromFirestore(data);
  }

  @override
  Future<void> saveColors(AppColorSettings colors) {
    return _remoteDataSource.saveColors(colors.toFirestore());
  }
}
