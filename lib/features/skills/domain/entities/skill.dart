import 'package:equatable/equatable.dart';

class Skill extends Equatable {
  const Skill({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.categoryId,
    required this.categoryAr,
    required this.categoryEn,
    required this.order,
  });

  final String id;

  final String nameAr;
  final String nameEn;

  final String categoryId;

  final String categoryAr;
  final String categoryEn;

  final int order;

  String name(String languageCode) {
    return languageCode == 'ar' ? nameAr : nameEn;
  }

  String category(String languageCode) {
    return languageCode == 'ar' ? categoryAr : categoryEn;
  }

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    categoryId,
    categoryAr,
    categoryEn,
    order,
  ];
}
