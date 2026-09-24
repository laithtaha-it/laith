import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/cv_locale_cubit.dart';
import '../../../cv_colors/domain/entities/cv_color_settings.dart';
import '../../../cv_colors/presentation/bloc/cv_colors_cubit.dart';
import '../../data/repositories/cv_repository_impl.dart';
import '../../domain/entities/cv_section.dart';
import '../../domain/repositories/cv_repository.dart';

class CvPage extends StatefulWidget {
  const CvPage({super.key});

  @override
  State<CvPage> createState() => _CvPageState();
}

class _CvPageState extends State<CvPage> {
  final CvRepository _repository = CvRepositoryImpl();
  late Future<List<CvSection>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getSections();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repository.getSections();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<CvLocaleCubit>().state.languageCode == 'ar';

    final cvColors = context.watch<CvColorsCubit>().state.colors;

    return Scaffold(
      backgroundColor: cvColors.background,
      body: CvColorsScope(
        colors: cvColors,
        child: SafeArea(
          child: Column(
            children: [
              _CvTopBar(isArabic: isArabic),

              Expanded(
                child: FutureBuilder<List<CvSection>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return _CvStateMessage(
                        message: isArabic
                            ? 'تعذر تحميل السيرة الذاتية.'
                            : 'Unable to load the CV.',
                        actionLabel: isArabic ? 'إعادة المحاولة' : 'Try again',
                        onAction: _reload,
                        isArabic: isArabic,
                      );
                    }

                    final sections =
                        (snapshot.data ?? <CvSection>[])
                            .where((section) => section.visible)
                            .toList()
                          ..sort((a, b) => a.order.compareTo(b.order));

                    if (sections.isEmpty) {
                      return _CvStateMessage(
                        message: isArabic
                            ? 'لا يوجد محتوى للسيرة الذاتية حتى الآن.'
                            : 'CV content is not available yet.',
                        actionLabel: isArabic ? 'إعادة التحميل' : 'Reload',
                        onAction: _reload,
                        isArabic: isArabic,
                      );
                    }

                    return SelectionArea(
                      child: RefreshIndicator(
                        onRefresh: _reload,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 700;

                            final horizontal = isMobile ? 20.0 : 44.0;
                            final vertical = isMobile ? 24.0 : 42.0;

                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontal,
                                vertical: vertical,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1080,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CvColorsScope.of(context).white,
                                      border: Border(
                                        top: BorderSide(
                                          color: CvColorsScope.of(
                                            context,
                                          ).dark2222,
                                          width: 6,
                                        ),
                                        bottom: BorderSide(
                                          color: CvColorsScope.of(
                                            context,
                                          ).dark2222,
                                          width: 6,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.14,
                                          ),
                                          blurRadius: 48,
                                          offset: const Offset(0, 24),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.fromLTRB(
                                      isMobile ? 22 : 42,
                                      isMobile ? 24 : 34,
                                      isMobile ? 22 : 42,
                                      isMobile ? 28 : 42,
                                    ),
                                    child: Directionality(
                                      textDirection: isArabic
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                      child: _CvDocument(
                                        sections: sections,
                                        isArabic: isArabic,
                                        isMobile: isMobile,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CvTopBar extends StatelessWidget {
  const _CvTopBar({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final colors = CvColorsScope.of(context);

    return Stack(
      children: [
        _CvBackButton(isArabic: isArabic),
        Align(
          alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: _CvLanguageButton(isArabic: isArabic, colors: colors),
          ),
        ),
      ],
    );
  }
}

class _CvBackButton extends StatelessWidget {
  const _CvBackButton({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final colors = CvColorsScope.of(context);

    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: IconButton(
          tooltip: isArabic ? 'رجوع' : 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: Icon(
            isArabic ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            size: 22,
            color: colors.dark2222,
          ),
        ),
      ),
    );
  }
}

class _CvLanguageButton extends StatelessWidget {
  const _CvLanguageButton({required this.isArabic, required this.colors});

  final bool isArabic;
  final CvColorSettings colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: () {
          context.read<CvLocaleCubit>().toggleLocale();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.dark2222.withValues(alpha: 0.35),
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language_rounded, size: 16, color: colors.dark2222),
              const SizedBox(width: 6),
              Text(
                isArabic ? 'EN' : 'AR',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: colors.dark2222,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CvDocument extends StatelessWidget {
  const _CvDocument({
    required this.sections,
    required this.isArabic,
    required this.isMobile,
  });

  final List<CvSection> sections;
  final bool isArabic;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final section in sections)
            section.type == 'profile'
                ? _ProfileSection(section: section, isArabic: isArabic)
                : _CvSection(
                    section: section,
                    isArabic: isArabic,
                    isMobile: isMobile,
                  ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.section, required this.isArabic});

  final CvSection section;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final data = section.data;

    final name = _value(data, 'name');
    final role = _value(data, 'role');
    final location = _value(data, 'location');
    final email = _value(data, 'email');
    final phone = _value(data, 'phone');
    final website = _value(data, 'website');
    final github = _value(data, 'github');
    final linkedin = _value(data, 'linkedin');

    final contact = <_CvLinkItem>[
      if (location.isNotEmpty) _CvLinkItem(location, ''),
      if (phone.isNotEmpty) _CvLinkItem(phone, 'tel:$phone'),
      if (email.isNotEmpty) _CvLinkItem(email, 'mailto:$email'),
      if (website.isNotEmpty && website != github)
        _CvLinkItem(website, website),
      if (github.isNotEmpty) _CvLinkItem(github, github),
      if (linkedin.isNotEmpty) _CvLinkItem(linkedin, linkedin),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (name.isNotEmpty)
            Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                name,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  fontSize: 34,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .1,
                  color: CvColorsScope.of(context).dark2020,
                ),
              ),
            ),
          if (role.isNotEmpty) ...[
            const SizedBox(height: 7),
            Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                role,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: CvColorsScope.of(context).dark3333,
                ),
              ),
            ),
          ],
          if (contact.isNotEmpty) ...[
            const SizedBox(height: 9),
            Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: Wrap(
                  alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
                  runSpacing: 5,
                  spacing: 7,
                  children: [
                    for (var i = 0; i < contact.length; i++) ...[
                      if (i > 0)
                        Text(
                          '|',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: CvColorsScope.of(context).gray7777,
                          ),
                        ),
                      contact[i].url.isEmpty
                          ? Text(
                              contact[i].label,
                              textDirection: isArabic
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 10.5,
                                height: 1.3,
                                color: CvColorsScope.of(context).gray5555,
                              ),
                            )
                          : _CvLink(item: contact[i]),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CvSection extends StatelessWidget {
  const _CvSection({
    required this.section,
    required this.isArabic,
    required this.isMobile,
  });

  final CvSection section;
  final bool isArabic;
  final bool isMobile;

  String get title {
    if (isArabic && section.titleAr.trim().isNotEmpty) {
      return section.titleAr.trim();
    }

    if (section.titleEn.trim().isNotEmpty) {
      return section.titleEn.trim();
    }

    return _defaultTitle(section.type, isArabic);
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (section.type) {
      'summary' => _SummaryBody(section: section, isArabic: isArabic),
      'experience' => _ExperienceBody(section: section, isArabic: isArabic),
      'education' => _EducationBody(section: section, isArabic: isArabic),
      'skills' => _SkillsBody(section: section, isArabic: isArabic),
      'projects' => _ProjectsBody(section: section, isArabic: isArabic),
      'certifications' => _CertificationsBody(
        section: section,
        isArabic: isArabic,
      ),
      'languages' => _LanguagesBody(section: section, isArabic: isArabic),
      _ => _CustomBody(section: section, isArabic: isArabic),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _SectionHeading(title: title, isArabic: isArabic),
          const SizedBox(height: 10),
          body,
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.isArabic});

  final String title;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            isArabic ? title : title.toUpperCase(),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: isArabic ? 0 : .25,
              color: CvColorsScope.of(context).dark2424,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Divider(
          height: 1,
          thickness: 1,
          color: CvColorsScope.of(context).dark2222,
        ),
      ],
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.section, required this.isArabic});

  final CvSection section;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final content = _localized(section.data, 'content', isArabic);

    return _Paragraph(text: content, isArabic: isArabic);
  }
}

class _ExperienceBody extends StatelessWidget {
  const _ExperienceBody({required this.section, required this.isArabic});

  final CvSection section;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final items = _mapItems(section.data);

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 16),
            child: _ExperienceItem(item: items[i], isArabic: isArabic),
          ),
      ],
    );
  }
}

class _ExperienceItem extends StatelessWidget {
  const _ExperienceItem({required this.item, required this.isArabic});

  final Map<String, dynamic> item;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final title = _localizedItem(item, 'title', isArabic);

    final company = _value(item, 'company');
    final location = _value(item, 'location');
    final start = _value(item, 'startDate');

    final end = item['current'] == true
        ? (isArabic ? 'حتى الآن' : 'Present')
        : _value(item, 'endDate');

    final date = _joinNonEmpty([start, end], ' – ');

    final bullets = _localizedBulletList(item, isArabic);

    final description = _localizedItem(item, 'description', isArabic);

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              title,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: CvColorsScope.of(context).dark2525,
              ),
            ),
          ),
        if (company.isNotEmpty || location.isNotEmpty || date.isNotEmpty) ...[
          const SizedBox(height: 3),
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              _joinNonEmpty([company, location, date], '  •  '),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                fontSize: 10.5,
                fontStyle: FontStyle.italic,
                color: CvColorsScope.of(context).gray5555,
              ),
            ),
          ),
        ],
        if (bullets.isNotEmpty) ...[
          const SizedBox(height: 6),
          _BulletList(items: bullets, isArabic: isArabic),
        ] else if (description.isNotEmpty) ...[
          const SizedBox(height: 6),
          _BulletText(text: description, isArabic: isArabic),
        ],
      ],
    );
  }
}

class _EducationBody extends StatelessWidget {
  const _EducationBody({required this.section, required this.isArabic});

  final CvSection section;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final items = _mapItems(section.data);

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 10),
            child: _EducationItem(item: items[i], isArabic: isArabic),
          ),
      ],
    );
  }
}

class _EducationItem extends StatelessWidget {
  const _EducationItem({required this.item, required this.isArabic});

  final Map<String, dynamic> item;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final degree = _localizedItem(item, 'degree', isArabic);

    final institution = _value(item, 'institution');

    final location = _value(item, 'location');

    final startDate = _value(item, 'startDate');

    final endDate = _value(item, 'endDate');

    final date = _joinNonEmpty([startDate, endDate], ' – ');

    final description = _localizedItem(item, 'description', isArabic);

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (degree.isNotEmpty)
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              degree,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: CvColorsScope.of(context).dark2525,
              ),
            ),
          ),
        if (institution.isNotEmpty || location.isNotEmpty || date.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                _joinNonEmpty([institution, location, date], '  •  '),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  fontSize: 10.2,
                  height: 1.3,
                  fontStyle: FontStyle.italic,
                  color: CvColorsScope.of(context).gray5555,
                ),
              ),
            ),
          ),
        if (description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: _Paragraph(text: description, isArabic: isArabic),
          ),
      ],
    );
  }
}

class _SkillsBody extends StatelessWidget {
  const _SkillsBody({required this.section, required this.isArabic});

  final CvSection section;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final items = _mapItems(section.data);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final item in items) {
      var category = _localizedItem(item, 'category', isArabic).trim();

      category = category.replaceFirst(RegExp(r':+\s*$'), '');

      final key = category.isEmpty
          ? (isArabic ? 'مهارات' : 'Skills')
          : category;

      grouped.putIfAbsent(key, () => []).add(item);
    }

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < grouped.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == grouped.length - 1 ? 0 : 4),
            child: _SkillRow(
              category: grouped.keys.elementAt(i),
              items: grouped.values.elementAt(i),
              isArabic: isArabic,
            ),
          ),
      ],
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.category,
    required this.items,
    required this.isArabic,
  });

  final String category;
  final List<Map<String, dynamic>> items;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final skills = items
        .map((item) => _localizedItem(item, 'name', isArabic).trim())
        .where((value) => value.isNotEmpty)
        .join(', ');

    if (skills.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: RichText(
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        text: TextSpan(
          style: TextStyle(
            fontSize: 10.5,
            height: 1.35,
            color: CvColorsScope.of(context).dark3030,
          ),
          children: [
            TextSpan(
              text: '$category: ',
              style: TextStyle(
                fontSize: 10.7,
                fontWeight: FontWeight.w800,
                color: CvColorsScope.of(context).dark2525,
              ),
            ),
            TextSpan(
              text: skills,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
                color: CvColorsScope.of(context).dark3030,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectsBody extends StatelessWidget {
  const _ProjectsBody({required this.section, required this.isArabic});

  final CvSection section;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final items = _mapItems(section.data);

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 15),
            child: _ProjectItem(item: items[i], isArabic: isArabic),
          ),
      ],
    );
  }
}

class _ProjectItem extends StatelessWidget {
  const _ProjectItem({required this.item, required this.isArabic});

  final Map<String, dynamic> item;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final title = _localizedItem(item, 'title', isArabic);

    final bullets = _localizedBulletList(item, isArabic);

    final description = _localizedItem(item, 'description', isArabic);

    final technologies = _stringList(item['technologies']);

    final url = _value(item, 'url');
    final githubUrl = _value(item, 'githubUrl');

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            title,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: CvColorsScope.of(context).dark2525,
            ),
          ),
        ),
        if (technologies.isNotEmpty) ...[
          const SizedBox(height: 4),
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              technologies.join('  •  '),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                fontSize: 9.8,
                fontStyle: FontStyle.italic,
                color: CvColorsScope.of(context).gray6666,
              ),
            ),
          ),
        ],
        if (bullets.isNotEmpty) ...[
          const SizedBox(height: 6),
          _BulletList(items: bullets, isArabic: isArabic),
        ] else if (description.isNotEmpty) ...[
          const SizedBox(height: 6),
          _BulletText(text: description, isArabic: isArabic),
        ],
        if (url.isNotEmpty || githubUrl.isNotEmpty) ...[
          const SizedBox(height: 5),
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Wrap(
                spacing: 10,
                runSpacing: 4,
                alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
                children: [
                  if (url.isNotEmpty)
                    _CvLink(
                      item: _CvLinkItem(
                        isArabic ? 'رابط المشروع' : 'Project',
                        url,
                      ),
                    ),
                  if (githubUrl.isNotEmpty)
                    _CvLink(item: _CvLinkItem('GitHub', githubUrl)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CertificationsBody extends StatelessWidget {
  const _CertificationsBody({required this.section, required this.isArabic});

  final CvSection section;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final items = _mapItems(section.data);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 9),
            child: _CertificationItem(item: items[i], isArabic: isArabic),
          ),
      ],
    );
  }
}

class _CertificationItem extends StatelessWidget {
  const _CertificationItem({required this.item, required this.isArabic});

  final Map<String, dynamic> item;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final name = _localizedItem(item, 'name', isArabic);

    final issuer = _localizedItem(item, 'issuer', isArabic);

    final date = _value(item, 'date');

    final url = _value(item, 'url').isNotEmpty
        ? _value(item, 'url')
        : _value(item, 'credentialUrl');

    if (name.isEmpty && issuer.isEmpty && date.isEmpty) {
      return const SizedBox.shrink();
    }

    final title = _joinNonEmpty([name, issuer], ' — ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        SizedBox(
          width: 12,
          child: Text(
            '•',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: CvColorsScope.of(context).black,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Wrap(
                alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 3,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: CvColorsScope.of(context).dark2525,
                      ),
                    ),
                  if (url.isNotEmpty) _CertificationUrlButton(url: url),
                  if (date.isNotEmpty)
                    Text(
                      date,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 9.8,
                        height: 1.3,
                        fontStyle: FontStyle.italic,
                        color: CvColorsScope.of(context).gray5555,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CertificationUrlButton extends StatelessWidget {
  const _CertificationUrlButton({required this.url});

  final String url;

  Future<void> _open() async {
    final raw = url.trim();

    if (raw.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(raw);

    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
        decoration: BoxDecoration(
          border: Border.all(
            color: CvColorsScope.of(context).accent,
            width: .7,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          'URL',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: 8.5,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: CvColorsScope.of(context).accent,
          ),
        ),
      ),
    );
  }
}

class _LanguagesBody extends StatelessWidget {
  const _LanguagesBody({required this.section, required this.isArabic});

  final CvSection section;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final items = _mapItems(section.data);

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 4),
            child: _LanguageItem(item: items[i], isArabic: isArabic),
          ),
      ],
    );
  }
}

class _LanguageItem extends StatelessWidget {
  const _LanguageItem({required this.item, required this.isArabic});

  final Map<String, dynamic> item;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final name = _localizedItem(item, 'name', isArabic);

    final level = _localizedItem(item, 'level', isArabic);

    if (name.isEmpty && level.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        SizedBox(
          width: 12,
          child: Text(
            '•',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              height: 1.35,
              fontWeight: FontWeight.w800,
              color: CvColorsScope.of(context).dark3333,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: RichText(
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              text: TextSpan(
                children: [
                  if (name.isNotEmpty)
                    TextSpan(
                      text: name,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                        color: CvColorsScope.of(context).dark2525,
                      ),
                    ),
                  if (name.isNotEmpty && level.isNotEmpty)
                    TextSpan(
                      text: ' — ',
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                        color: CvColorsScope.of(context).dark3030,
                      ),
                    ),
                  if (level.isNotEmpty)
                    TextSpan(
                      text: level,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                        color: CvColorsScope.of(context).dark3030,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomBody extends StatelessWidget {
  const _CustomBody({required this.section, required this.isArabic});

  final CvSection section;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final data = section.data;

    final content = _localized(data, 'content', isArabic);

    final items = _mapItems(data);

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (content.isNotEmpty) _Paragraph(text: content, isArabic: isArabic),
        if (items.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: content.isEmpty ? 0 : 7),
            child: _BulletList(
              items: [
                for (final item in items)
                  _localizedItem(item, 'content', isArabic).isNotEmpty
                      ? _localizedItem(item, 'content', isArabic)
                      : _localizedItem(item, 'title', isArabic),
              ],
              isArabic: isArabic,
            ),
          ),
      ],
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text, required this.isArabic});

  final String text;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.replaceFirst(RegExp(r'^\s*[-•*]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.length <= 1) {
      return _Paragraph(text: text, isArabic: isArabic);
    }

    return _BulletList(items: lines, isArabic: isArabic);
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items, required this.isArabic});

  final List<String> items;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final cleanItems = items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        for (final item in cleanItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                SizedBox(
                  width: 12,
                  child: Text(
                    '•',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.45,
                      fontWeight: FontWeight.w800,
                      color: CvColorsScope.of(context).dark3333,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Align(
                    alignment: isArabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      item,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 10.2,
                        height: 1.45,
                        color: CvColorsScope.of(context).dark3333,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.text, required this.isArabic});

  final String text;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        style: TextStyle(
          fontSize: 10.2,
          height: 1.45,
          color: CvColorsScope.of(context).dark3333,
        ),
      ),
    );
  }
}

class _CvLinkItem {
  const _CvLinkItem(this.label, this.url);

  final String label;
  final String url;
}

class _CvLink extends StatelessWidget {
  const _CvLink({required this.item});

  final _CvLinkItem item;

  Future<void> _open() async {
    final raw = item.url.trim();

    if (raw.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(raw);

    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _containsArabic(item.label);

    return InkWell(
      onTap: _open,
      child: Text(
        item.label,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 9.2,
          height: 1.3,
          color: CvColorsScope.of(context).accent,
          decoration: TextDecoration.underline,
          decorationColor: CvColorsScope.of(context).accent,
        ),
      ),
    );
  }
}

class _CvStateMessage extends StatelessWidget {
  const _CvStateMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.isArabic,
  });

  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> _mapItems(Map<String, dynamic> data) {
  final raw = data['items'];

  if (raw is! List) {
    return const <Map<String, dynamic>>[];
  }

  return raw
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String _value(Map<String, dynamic> data, String key) {
  return data[key]?.toString().trim() ?? '';
}

String _localized(Map<String, dynamic> data, String baseKey, bool isArabic) {
  final preferred = _value(data, '$baseKey${isArabic ? 'Ar' : 'En'}');

  if (preferred.isNotEmpty) {
    return preferred;
  }

  return _value(data, '$baseKey${isArabic ? 'En' : 'Ar'}');
}

String _localizedItem(
  Map<String, dynamic> item,
  String baseKey,
  bool isArabic,
) {
  final preferred = _value(item, '$baseKey${isArabic ? 'Ar' : 'En'}');

  if (preferred.isNotEmpty) {
    return preferred;
  }

  return _value(item, '$baseKey${isArabic ? 'En' : 'Ar'}');
}

List<String> _localizedBulletList(Map<String, dynamic> item, bool isArabic) {
  final primary = _stringList(item[isArabic ? 'bulletsAr' : 'bulletsEn']);

  if (primary.isNotEmpty) {
    return primary;
  }

  return _stringList(item[isArabic ? 'bulletsEn' : 'bulletsAr']);
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  if (value is String) {
    return value
        .split(RegExp(r'[,\n•|]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  return const <String>[];
}

String _joinNonEmpty(List<String> values, String separator) {
  return values.map((e) => e.trim()).where((e) => e.isNotEmpty).join(separator);
}

bool _containsArabic(String value) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
}

String _defaultTitle(String type, bool isArabic) {
  if (isArabic) {
    return switch (type) {
      'summary' => 'الملخص المهني',
      'experience' => 'الخبرة العملية',
      'education' => 'التعليم',
      'skills' => 'المهارات التقنية',
      'projects' => 'المشاريع',
      'certifications' => 'الشهادات والجوائز',
      'languages' => 'اللغات',
      _ => 'قسم إضافي',
    };
  }

  return switch (type) {
    'summary' => 'Professional Summary',
    'experience' => 'Experience',
    'education' => 'Education',
    'skills' => 'Technical Skills',
    'projects' => 'Projects',
    'certifications' => 'Certifications & Awards',
    'languages' => 'Languages',
    _ => 'Additional Section',
  };
}
