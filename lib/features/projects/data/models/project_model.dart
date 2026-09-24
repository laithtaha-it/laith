import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.titleAr,
    required super.titleEn,
    required super.shortDescriptionAr,
    required super.shortDescriptionEn,
    required super.descriptionAr,
    required super.descriptionEn,
    required super.imageUrl,
    required super.galleryImages,
    required super.technologies,
    required super.githubUrl,
    required super.liveUrl,
    required super.showOnHome,
    required super.featured,
    required super.order,
    required super.published,
  });

  factory ProjectModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final title = _localizedMap(data['title']);
    final shortDescription = _localizedMap(data['shortDescription']);
    final description = _localizedMap(data['description']);

    return ProjectModel(
      id: id,
      titleAr: _stringValue(title['ar']),
      titleEn: _stringValue(title['en']),
      shortDescriptionAr: _stringValue(shortDescription['ar']),
      shortDescriptionEn: _stringValue(shortDescription['en']),
      descriptionAr: _stringValue(description['ar']),
      descriptionEn: _stringValue(description['en']),
      imageUrl: _stringValue(data['imageUrl']),
      galleryImages: _stringList(data['galleryImages']),
      technologies: _stringList(data['technologies']),
      githubUrl: _optionalString(data['githubUrl']),
      liveUrl: _optionalString(data['liveUrl']),
      showOnHome: _boolValue(data['showOnHome']),
      featured: _boolValue(data['featured']),
      order: _intValue(data['order']),
      published: _boolValue(data['published']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': {
        'ar': titleAr,
        'en': titleEn,
      },
      'shortDescription': {
        'ar': shortDescriptionAr,
        'en': shortDescriptionEn,
      },
      'description': {
        'ar': descriptionAr,
        'en': descriptionEn,
      },
      'imageUrl': imageUrl,
      'galleryImages': galleryImages,
      'technologies': technologies,
      'githubUrl': githubUrl,
      'liveUrl': liveUrl,
      'showOnHome': showOnHome,
      'featured': featured,
      'order': order,
      'published': published,
    };
  }

  static Map<String, dynamic> _localizedMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const <String, dynamic>{};
  }

  static String _stringValue(Object? value) =>
      value is String ? value.trim() : '';

  static String? _optionalString(Object? value) {
    final string = _stringValue(value);
    return string.isEmpty ? null : string;
  }

  static bool _boolValue(Object? value) => value is bool ? value : false;

  static int _intValue(Object? value) => value is num ? value.toInt() : 0;

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return List<String>.unmodifiable(
      value.whereType<String>().map((item) => item.trim()).where(
            (item) => item.isNotEmpty,
          ),
    );
  }
}
