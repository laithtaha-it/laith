import '../../domain/entities/app_color_settings.dart';

class AppColorSettingsModel extends AppColorSettings {
  const AppColorSettingsModel({
    required super.scaffoldBackground,
    required super.surface,
    required super.primaryText,
    required super.secondaryText,
    required super.accent,
    required super.border,
    required super.error,
    required super.success,
  });

  factory AppColorSettingsModel.fromEntity(AppColorSettings entity) {
    return AppColorSettingsModel(
      scaffoldBackground: entity.scaffoldBackground,
      surface: entity.surface,
      primaryText: entity.primaryText,
      secondaryText: entity.secondaryText,
      accent: entity.accent,
      border: entity.border,
      error: entity.error,
      success: entity.success,
    );
  }

  factory AppColorSettingsModel.fromFirestore(Map<String, dynamic> data) {
    final entity = AppColorSettings.fromFirestore(data);
    return AppColorSettingsModel.fromEntity(entity);
  }
}
