import 'package:equatable/equatable.dart';

class HomeContent extends Equatable {
  const HomeContent({
    required this.nameAr,
    required this.nameEn,
    required this.roleAr,
    required this.roleEn,
    required this.headlineAr,
    required this.headlineEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.projectsButtonAr,
    required this.projectsButtonEn,
    required this.contactButtonAr,
    required this.contactButtonEn,
    required this.about,
    required this.projects,
    required this.skills,
  });

  final String nameAr;
  final String nameEn;

  final String roleAr;
  final String roleEn;

  final String headlineAr;
  final String headlineEn;

  final String descriptionAr;
  final String descriptionEn;

  final String projectsButtonAr;
  final String projectsButtonEn;

  final String contactButtonAr;
  final String contactButtonEn;

  final AboutContent about;
  final ProjectsContent projects;
  final SkillsContent skills;

  String name(String languageCode) {
    return languageCode == 'ar' ? nameAr : nameEn;
  }

  String role(String languageCode) {
    return languageCode == 'ar' ? roleAr : roleEn;
  }

  String headline(String languageCode) {
    return languageCode == 'ar' ? headlineAr : headlineEn;
  }

  String description(String languageCode) {
    return languageCode == 'ar' ? descriptionAr : descriptionEn;
  }

  String projectsButton(String languageCode) {
    return languageCode == 'ar' ? projectsButtonAr : projectsButtonEn;
  }

  String contactButton(String languageCode) {
    return languageCode == 'ar' ? contactButtonAr : contactButtonEn;
  }

  @override
  List<Object?> get props => [
    nameAr,
    nameEn,
    roleAr,
    roleEn,
    headlineAr,
    headlineEn,
    descriptionAr,
    descriptionEn,
    projectsButtonAr,
    projectsButtonEn,
    contactButtonAr,
    contactButtonEn,
    about,
    projects,
    skills,
  ];
}

// ============================================================
// ABOUT
// ============================================================

class AboutContent extends Equatable {
  const AboutContent({
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.cvUrlAr,
    required this.cvUrlEn,
  });

  final String titleAr;
  final String titleEn;

  final String descriptionAr;
  final String descriptionEn;

  final String cvUrlAr;
  final String cvUrlEn;

  String title(String languageCode) {
    return languageCode == 'ar' ? titleAr : titleEn;
  }

  String description(String languageCode) {
    return languageCode == 'ar' ? descriptionAr : descriptionEn;
  }

  String cvUrl(String languageCode) {
    return languageCode == 'ar' ? cvUrlAr : cvUrlEn;
  }

  @override
  List<Object?> get props => [
    titleAr,
    titleEn,
    descriptionAr,
    descriptionEn,
    cvUrlAr,
    cvUrlEn,
  ];
}

// ============================================================
// PROJECTS
// ============================================================

class ProjectsContent extends Equatable {
  const ProjectsContent({
    required this.eyebrowAr,
    required this.eyebrowEn,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
  });

  final String eyebrowAr;
  final String eyebrowEn;

  final String titleAr;
  final String titleEn;

  final String descriptionAr;
  final String descriptionEn;

  String eyebrow(String languageCode) {
    return languageCode == 'ar' ? eyebrowAr : eyebrowEn;
  }

  String title(String languageCode) {
    return languageCode == 'ar' ? titleAr : titleEn;
  }

  String description(String languageCode) {
    return languageCode == 'ar' ? descriptionAr : descriptionEn;
  }

  @override
  List<Object?> get props => [
    eyebrowAr,
    eyebrowEn,
    titleAr,
    titleEn,
    descriptionAr,
    descriptionEn,
  ];
}

// ============================================================
// SKILLS
// ============================================================

class SkillsContent extends Equatable {
  const SkillsContent({
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
  });

  final String titleAr;
  final String titleEn;

  final String descriptionAr;
  final String descriptionEn;

  String title(String languageCode) {
    return languageCode == 'ar' ? titleAr : titleEn;
  }

  String description(String languageCode) {
    return languageCode == 'ar' ? descriptionAr : descriptionEn;
  }

  @override
  List<Object?> get props => [titleAr, titleEn, descriptionAr, descriptionEn];
}
