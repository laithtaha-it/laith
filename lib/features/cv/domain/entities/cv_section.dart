class CvSection {
  const CvSection({
    required this.id,
    required this.type,
    required this.titleAr,
    required this.titleEn,
    required this.visible,
    required this.order,
    required this.data,
  });

  final String id;
  final String type;
  final String titleAr;
  final String titleEn;
  final bool visible;
  final int order;
  final Map<String, dynamic> data;

  factory CvSection.fromMap(String id, Map<String, dynamic> map) {
    final rawData = map['data'];
    return CvSection(
      id: id,
      type: map['type']?.toString() ?? 'custom',
      titleAr: map['titleAr']?.toString() ?? '',
      titleEn: map['titleEn']?.toString() ?? '',
      visible: map['visible'] is bool ? map['visible'] as bool : true,
      order: (map['order'] as num?)?.toInt() ?? 0,
      data: rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'visible': visible,
        'order': order,
        'data': data,
      };
}
