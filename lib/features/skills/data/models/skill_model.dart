import '../../domain/entities/skill.dart';

class SkillModel extends Skill {
  const SkillModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.categoryId,
    required super.categoryAr,
    required super.categoryEn,
    required super.order,
  });

  factory SkillModel.fromMap(String id, Map<String, dynamic> map) {
    final name = _localizedValue(map['name']);
    final category = _localizedValue(map['category']);

    return SkillModel(
      id: id,
      nameAr: name.ar,
      nameEn: name.en,
      categoryId: map['categoryId']?.toString() ?? '',
      categoryAr: category.ar,
      categoryEn: category.en,
      order: _parseOrder(map['order']),
    );
  }

  static int _parseOrder(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
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
