import 'package:equatable/equatable.dart';

class ContactContent extends Equatable {
  const ContactContent({
    required this.sectionTitleAr,
    required this.sectionTitleEn,
    required this.sectionDescriptionAr,
    required this.sectionDescriptionEn,
    required this.sectionButtonAr,
    required this.sectionButtonEn,
    required this.email,
    required this.phone,
    required this.github,
    required this.linkedin,
    required this.instagram,
    required this.footerNameAr,
    required this.footerNameEn,
    required this.footerCopyrightAr,
    required this.footerCopyrightEn,
    required this.footerBuiltWithAr,
    required this.footerBuiltWithEn,
  });

  final String sectionTitleAr;
  final String sectionTitleEn;
  final String sectionDescriptionAr;
  final String sectionDescriptionEn;
  final String sectionButtonAr;
  final String sectionButtonEn;

  final String email;
  final String phone;
  final String github;
  final String linkedin;
  final String instagram;

  final String footerNameAr;
  final String footerNameEn;
  final String footerCopyrightAr;
  final String footerCopyrightEn;
  final String footerBuiltWithAr;
  final String footerBuiltWithEn;

  String sectionTitle(String languageCode) {
    return languageCode == 'ar' ? sectionTitleAr : sectionTitleEn;
  }

  String sectionDescription(String languageCode) {
    return languageCode == 'ar'
        ? sectionDescriptionAr
        : sectionDescriptionEn;
  }

  String sectionButton(String languageCode) {
    return languageCode == 'ar' ? sectionButtonAr : sectionButtonEn;
  }

  String footerName(String languageCode) {
    return languageCode == 'ar' ? footerNameAr : footerNameEn;
  }

  String footerCopyright(String languageCode) {
    return languageCode == 'ar' ? footerCopyrightAr : footerCopyrightEn;
  }

  String footerBuiltWith(String languageCode) {
    return languageCode == 'ar' ? footerBuiltWithAr : footerBuiltWithEn;
  }

  @override
  List<Object?> get props => [
    sectionTitleAr,
    sectionTitleEn,
    sectionDescriptionAr,
    sectionDescriptionEn,
    sectionButtonAr,
    sectionButtonEn,
    email,
    phone,
    github,
    linkedin,
    instagram,
    footerNameAr,
    footerNameEn,
    footerCopyrightAr,
    footerCopyrightEn,
    footerBuiltWithAr,
    footerBuiltWithEn,
  ];
}
