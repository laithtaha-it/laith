import '../../domain/entities/cv_color_settings.dart';
import '../../domain/repositories/cv_colors_repository.dart';
import '../datasources/cv_colors_remote_data_source.dart';

class CvColorsRepositoryImpl implements CvColorsRepository {
  CvColorsRepositoryImpl({required CvColorsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CvColorsRemoteDataSource _remoteDataSource;

  @override
  Future<CvColorSettings> getColors() async {
    final data = await _remoteDataSource.getColors();
    if (data.isEmpty) return CvColorSettings.defaults;
    return CvColorSettings.fromFirestore(data);
  }

  @override
  Future<void> saveColors(CvColorSettings colors) =>
      _remoteDataSource.saveColors(colors.toFirestore());
}
