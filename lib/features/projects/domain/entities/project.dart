import 'package:equatable/equatable.dart';

class Project extends Equatable {
  const Project({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.shortDescriptionAr,
    required this.shortDescriptionEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imageUrl,
    required this.galleryImages,
    required this.technologies,
    required this.githubUrl,
    required this.liveUrl,
    required this.showOnHome,
    required this.featured,
    required this.order,
    required this.published,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String shortDescriptionAr;
  final String shortDescriptionEn;
  final String descriptionAr;
  final String descriptionEn;
  final String imageUrl;
  final List<String> galleryImages;
  final List<String> technologies;
  final String? githubUrl;
  final String? liveUrl;
  final bool showOnHome;
  final bool featured;
  final int order;
  final bool published;

  String title(String languageCode) => languageCode == 'ar' ? titleAr : titleEn;

  String shortDescription(String languageCode) =>
      languageCode == 'ar' ? shortDescriptionAr : shortDescriptionEn;

  String description(String languageCode) =>
      languageCode == 'ar' ? descriptionAr : descriptionEn;

  @override
  List<Object?> get props => [
    id,
    titleAr,
    titleEn,
    shortDescriptionAr,
    shortDescriptionEn,
    descriptionAr,
    descriptionEn,
    imageUrl,
    galleryImages,
    technologies,
    githubUrl,
    liveUrl,
    showOnHome,
    featured,
    order,
    published,
  ];
}
