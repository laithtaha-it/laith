import 'package:flutter/material.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/admin_content_repository.dart';
import '../widgets/admin_scaffold.dart';

class AdminSingletonEditorPage extends StatefulWidget {
  const AdminSingletonEditorPage({required this.type, super.key});

  final AdminEditorType type;

  @override
  State<AdminSingletonEditorPage> createState() =>
      _AdminSingletonEditorPageState();
}

class _AdminSingletonEditorPageState extends State<AdminSingletonEditorPage> {
  final _repo = AdminContentRepository();

  final Map<String, TextEditingController> _controllers = {};

  bool _loading = true;
  bool _saving = false;

  // ---------------------------------------------------------------------------
  // Collection
  // ---------------------------------------------------------------------------

  String get _collection => switch (widget.type) {
    AdminEditorType.home => FirestoreCollections.siteContent,
    AdminEditorType.about => FirestoreCollections.about,
    AdminEditorType.contact => FirestoreCollections.contact,
  };

  // ---------------------------------------------------------------------------
  // Document
  // ---------------------------------------------------------------------------

  String get _documentId =>
      widget.type == AdminEditorType.home ? 'home' : 'main';

  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  List<String> get _fields => switch (widget.type) {
    AdminEditorType.home => [
      'nameAr',
      'nameEn',
      'roleAr',
      'roleEn',
      'headlineAr',
      'headlineEn',
      'descriptionAr',
      'descriptionEn',
      'projectsButtonAr',
      'projectsButtonEn',
      'contactButtonAr',
      'contactButtonEn',
    ],

    AdminEditorType.about => [
      'titleAr',
      'titleEn',
      'descriptionAr',
      'descriptionEn',
      'cvUrlAr',
      'cvUrlEn',
    ],

    AdminEditorType.contact => [
      // Contact section content
      'sectionTitleAr',
      'sectionTitleEn',
      'sectionDescriptionAr',
      'sectionDescriptionEn',
      'sectionButtonAr',
      'sectionButtonEn',

      // Contact information
      'email',
      'phone',
      'github',
      'linkedin',
      'instagram',

      // Footer
      'footerNameAr',
      'footerNameEn',
      'footerCopyrightAr',
      'footerCopyrightEn',
      'footerBuiltWithAr',
      'footerBuiltWithEn',
    ],
  };

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ---------------------------------------------------------------------------
  // Read localized value
  // ---------------------------------------------------------------------------

  String _readLocalized(Map<String, dynamic> data, String key, String lang) {
    final value = data[key];

    return value is Map ? value[lang]?.toString() ?? '' : '';
  }

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> _load() async {
    try {
      final data = await _repo.getDocument(_collection, _documentId);

      for (final field in _fields) {
        final isHome = widget.type == AdminEditorType.home;

        final isContactLocalized =
            widget.type == AdminEditorType.contact &&
            (field.startsWith('section') || field.startsWith('footer'));

        final isLocalized = isHome || isContactLocalized;

        String value;

        if (isLocalized) {
          final base = field.replaceFirst(RegExp(r'(Ar|En)$'), '');

          final lang = field.endsWith('Ar') ? 'ar' : 'en';

          value = _readLocalized(data, base, lang);
        } else {
          value = data[field]?.toString() ?? '';
        }

        _controllers[field] = TextEditingController(text: value);
      }

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load data: $error')));
    }
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      Map<String, dynamic> data;

      if (widget.type == AdminEditorType.home) {
        data = <String, dynamic>{};

        for (final field in _fields) {
          final base = field.replaceFirst(RegExp(r'(Ar|En)$'), '');

          final lang = field.endsWith('Ar') ? 'ar' : 'en';

          final existing = data[base] is Map
              ? Map<String, dynamic>.from(data[base] as Map)
              : <String, dynamic>{};

          existing[lang] = _controllers[field]!.text.trim();

          data[base] = existing;
        }
      } else if (widget.type == AdminEditorType.contact) {
        data = <String, dynamic>{};

        for (final field in _fields) {
          final isContactLocalized =
              field.startsWith('section') || field.startsWith('footer');

          if (isContactLocalized) {
            final base = field.replaceFirst(RegExp(r'(Ar|En)$'), '');

            final lang = field.endsWith('Ar') ? 'ar' : 'en';

            final existing = data[base] is Map
                ? Map<String, dynamic>.from(data[base] as Map)
                : <String, dynamic>{};

            existing[lang] = _controllers[field]!.text.trim();

            data[base] = existing;
          } else {
            data[field] = _controllers[field]!.text.trim();
          }
        }
      } else {
        data = {
          for (final field in _fields) field: _controllers[field]!.text.trim(),
        };
      }

      await _repo.saveDocument(_collection, _documentId, data);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved successfully.')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save changes: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Label
  // ---------------------------------------------------------------------------

  String _label(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceFirstMapped(
          RegExp(r'^[a-z]'),
          (match) => match.group(0)!.toUpperCase(),
        );
  }

  // ---------------------------------------------------------------------------
  // Field Group
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isContact = widget.type == AdminEditorType.contact;

    return AdminScaffold(
      title: widget.type.label,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.type.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    const SizedBox(height: 24),

                    if (isContact) ...[
                      _sectionTitle(context, 'Contact Section'),

                      ..._buildFields(
                        _fields.where((field) => field.startsWith('section')),
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle(context, 'Contact Information'),

                      ..._buildFields(
                        _fields.where(
                          (field) =>
                              !field.startsWith('section') &&
                              !field.startsWith('footer'),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle(context, 'Footer'),

                      ..._buildFields(
                        _fields.where((field) => field.startsWith('footer')),
                      ),
                    ] else ...[
                      ..._buildFields(_fields),
                    ],

                    const SizedBox(height: 8),

                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_saving ? 'Saving…' : 'Save changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build Fields
  // ---------------------------------------------------------------------------

  List<Widget> _buildFields(Iterable<String> fields) {
    return fields.map((field) {
      final controller = _controllers[field];

      if (controller == null) {
        return const SizedBox.shrink();
      }

      final isDescription =
          field.toLowerCase().contains('description') ||
          field.toLowerCase().contains('copyright') ||
          field.toLowerCase().contains('builtwith');

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: controller,
          maxLines: isDescription ? 4 : 1,
          decoration: InputDecoration(labelText: _label(field)),
        ),
      );
    }).toList();
  }
}

// =============================================================================
// Admin Editor Type
// =============================================================================

enum AdminEditorType {
  home,
  about,
  contact;

  String get label => switch (this) {
    home => 'Home',
    about => 'About',
    contact => 'Contact',
  };

  String get description => switch (this) {
    home => 'Edit the main Hero content and buttons.',

    about => 'Edit About content and CV links.',

    contact =>
      'Edit the contact section, contact details, and footer content used across the website.',
  };
}
