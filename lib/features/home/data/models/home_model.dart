import '../../domain/entities/home_content.dart';

class HomeModel extends HomeContent {
  const HomeModel({
    required super.nameAr,
    required super.nameEn,
    required super.roleAr,
    required super.roleEn,
    required super.headlineAr,
    required super.headlineEn,
    required super.descriptionAr,
    required super.descriptionEn,
    required super.projectsButtonAr,
    required super.projectsButtonEn,
    required super.contactButtonAr,
    required super.contactButtonEn,
    required super.about,
    required super.projects,
    required super.skills,
  });

  factory HomeModel.fromMap(Map<String, dynamic> map) {
    final name = _localizedValue(map['name']);
    final role = _localizedValue(map['role']);
    final headline = _localizedValue(map['headline']);
    final description = _localizedValue(map['description']);
    final projectsButton = _localizedValue(map['projectsButton']);
    final contactButton = _localizedValue(map['contactButton']);

    final about = _aboutContent(map['about']);
    final projects = _projectsContent(map['projects']);
    final skills = _skillsContent(map['skills']);

    return HomeModel(
      nameAr: name.ar,
      nameEn: name.en,
      roleAr: role.ar,
      roleEn: role.en,
      headlineAr: headline.ar,
      headlineEn: headline.en,
      descriptionAr: description.ar,
      descriptionEn: description.en,
      projectsButtonAr: projectsButton.ar,
      projectsButtonEn: projectsButton.en,
      contactButtonAr: contactButton.ar,
      contactButtonEn: contactButton.en,
      about: about,
      projects: projects,
      skills: skills,
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  static AboutContent _aboutContent(dynamic value) {
    if (value is! Map) {
      return const AboutContent(
        titleAr: '',
        titleEn: '',
        descriptionAr: '',
        descriptionEn: '',
        cvUrlAr: '',
        cvUrlEn: '',
      );
    }

    return AboutContent(
      titleAr: value['titleAr']?.toString() ?? '',
      titleEn: value['titleEn']?.toString() ?? '',
      descriptionAr: value['descriptionAr']?.toString() ?? '',
      descriptionEn: value['descriptionEn']?.toString() ?? '',
      cvUrlAr: value['cvUrlAr']?.toString() ?? '',
      cvUrlEn: value['cvUrlEn']?.toString() ?? '',
    );
  }

  // ============================================================
  // PROJECTS
  // ============================================================

  static ProjectsContent _projectsContent(dynamic value) {
    if (value is! Map) {
      return const ProjectsContent(
        eyebrowAr: '',
        eyebrowEn: '',
        titleAr: '',
        titleEn: '',
        descriptionAr: '',
        descriptionEn: '',
      );
    }

    return ProjectsContent(
      eyebrowAr: value['eyebrowAr']?.toString() ?? '',
      eyebrowEn: value['eyebrowEn']?.toString() ?? '',
      titleAr: value['titleAr']?.toString() ?? '',
      titleEn: value['titleEn']?.toString() ?? '',
      descriptionAr: value['descriptionAr']?.toString() ?? '',
      descriptionEn: value['descriptionEn']?.toString() ?? '',
    );
  }

  // ============================================================
  // SKILLS
  // ============================================================

  static SkillsContent _skillsContent(dynamic value) {
    if (value is! Map) {
      return const SkillsContent(
        titleAr: '',
        titleEn: '',
        descriptionAr: '',
        descriptionEn: '',
      );
    }

    return SkillsContent(
      titleAr: value['titleAr']?.toString() ?? '',
      titleEn: value['titleEn']?.toString() ?? '',
      descriptionAr: value['descriptionAr']?.toString() ?? '',
      descriptionEn: value['descriptionEn']?.toString() ?? '',
    );
  }

  // ============================================================
  // LOCALIZED VALUE
  // ============================================================

  static _LocalizedValue _localizedValue(dynamic value) {
    if (value is! Map) {
      return const _LocalizedValue(ar: '', en: '');
    }

    return _LocalizedValue(
      ar: value['ar']?.toString() ?? '',
      en: value['en']?.toString() ?? '',
    );
  }
}

class _LocalizedValue {
  const _LocalizedValue({required this.ar, required this.en});

  final String ar;
  final String en;
}
