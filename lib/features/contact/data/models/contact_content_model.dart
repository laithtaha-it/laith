import '../../domain/entities/contact_content.dart';

class ContactContentModel extends ContactContent {
  const ContactContentModel({
    required super.sectionTitleAr,
    required super.sectionTitleEn,
    required super.sectionDescriptionAr,
    required super.sectionDescriptionEn,
    required super.sectionButtonAr,
    required super.sectionButtonEn,
    required super.email,
    required super.phone,
    required super.github,
    required super.linkedin,
    required super.instagram,
    required super.footerNameAr,
    required super.footerNameEn,
    required super.footerCopyrightAr,
    required super.footerCopyrightEn,
    required super.footerBuiltWithAr,
    required super.footerBuiltWithEn,
  });

  factory ContactContentModel.fromMap(Map<String, dynamic> map) {
    final sectionTitle = _localizedValue(map['sectionTitle']);
    final sectionDescription = _localizedValue(map['sectionDescription']);
    final sectionButton = _localizedValue(map['sectionButton']);
    final footerName = _localizedValue(map['footerName']);
    final footerCopyright = _localizedValue(map['footerCopyright']);
    final footerBuiltWith = _localizedValue(map['footerBuiltWith']);

    return ContactContentModel(
      sectionTitleAr: sectionTitle.ar,
      sectionTitleEn: sectionTitle.en,
      sectionDescriptionAr: sectionDescription.ar,
      sectionDescriptionEn: sectionDescription.en,
      sectionButtonAr: sectionButton.ar,
      sectionButtonEn: sectionButton.en,
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      github: map['github']?.toString() ?? '',
      linkedin: map['linkedin']?.toString() ?? '',
      instagram: map['instagram']?.toString() ?? '',
      footerNameAr: footerName.ar,
      footerNameEn: footerName.en,
      footerCopyrightAr: footerCopyright.ar,
      footerCopyrightEn: footerCopyright.en,
      footerBuiltWithAr: footerBuiltWith.ar,
      footerBuiltWithEn: footerBuiltWith.en,
    );
  }

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
