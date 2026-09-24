import '../entities/cv_color_settings.dart';

abstract interface class CvColorsRepository {
  Future<CvColorSettings> getColors();
  Future<void> saveColors(CvColorSettings colors);
}
