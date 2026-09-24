import '../entities/app_color_settings.dart';

abstract interface class ColorsRepository {
  Future<AppColorSettings> getColors();
  Future<void> saveColors(AppColorSettings colors);
}
