import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/admin_content_repository.dart';
import '../widgets/admin_scaffold.dart';

class AdminProjectsPage extends StatefulWidget {
  const AdminProjectsPage({super.key});

  @override
  State<AdminProjectsPage> createState() => _AdminProjectsPageState();
}

class _AdminProjectsPageState extends State<AdminProjectsPage> {
  final _repo = AdminContentRepository();

  bool _loading = true;
  bool _sectionSaving = false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _projects = [];

  // ---------------------------------------------------------------------------
  // Projects Section Content
  // ---------------------------------------------------------------------------

  final _eyebrowArController = TextEditingController();
  final _eyebrowEnController = TextEditingController();

  final _titleArController = TextEditingController();
  final _titleEnController = TextEditingController();

  final _descriptionArController = TextEditingController();
  final _descriptionEnController = TextEditingController();

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> _load() async {
    try {
      final result = await Future.wait([
        _repo.getCollection(FirestoreCollections.projects),
        FirebaseFirestore.instance
            .collection(FirestoreCollections.siteContent)
            .doc('home')
            .get(),
      ]);

      _projects =
          result[0] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;

      final homeDocument = result[1] as DocumentSnapshot<Map<String, dynamic>>;

      _loadSectionContent(homeDocument.data());

      _projects.sort((a, b) => _order(a).compareTo(_order(b)));

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load Projects data: $error')),
      );
    }
  }

  void _loadSectionContent(Map<String, dynamic>? homeData) {
    final projectsData = homeData?['projects'];

    if (projectsData is! Map) {
      return;
    }

    _eyebrowArController.text = projectsData['eyebrowAr']?.toString() ?? '';

    _eyebrowEnController.text = projectsData['eyebrowEn']?.toString() ?? '';

    _titleArController.text = projectsData['titleAr']?.toString() ?? '';

    _titleEnController.text = projectsData['titleEn']?.toString() ?? '';

    _descriptionArController.text =
        projectsData['descriptionAr']?.toString() ?? '';

    _descriptionEnController.text =
        projectsData['descriptionEn']?.toString() ?? '';
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int _order(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    return (document.data()['order'] as num?)?.toInt() ?? 0;
  }

  String _localized(Object? value, String lang) {
    return value is Map ? value[lang]?.toString() ?? '' : '';
  }

  String _slug(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  // ---------------------------------------------------------------------------
  // Save Projects Section Content
  // ---------------------------------------------------------------------------

  Future<void> _saveProjectsSectionContent() async {
    if (_sectionSaving) {
      return;
    }

    setState(() {
      _sectionSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.siteContent)
          .doc('home')
          .set({
            'projects': {
              'eyebrowAr': _eyebrowArController.text.trim(),
              'eyebrowEn': _eyebrowEnController.text.trim(),
              'titleAr': _titleArController.text.trim(),
              'titleEn': _titleEnController.text.trim(),
              'descriptionAr': _descriptionArController.text.trim(),
              'descriptionEn': _descriptionEnController.text.trim(),
            },
          }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projects section content saved successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save Projects section: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sectionSaving = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Add / Edit Project
  // ---------------------------------------------------------------------------

  Future<void> _edit({String? id, Map<String, dynamic>? data}) async {
    final result = await showDialog<_ProjectFormResult>(
      context: context,
      builder: (dialogContext) {
        return _ProjectEditorDialog(id: id, data: data);
      },
    );

    if (result == null || !mounted) {
      return;
    }

    final newId =
        id ?? _slug(result.titleEn.isEmpty ? result.titleAr : result.titleEn);

    if (newId.isEmpty) {
      return;
    }

    try {
      await _repo.saveDocument(FirestoreCollections.projects, newId, {
        'title': {'ar': result.titleAr.trim(), 'en': result.titleEn.trim()},

        'shortDescription': {
          'ar': result.shortAr.trim(),
          'en': result.shortEn.trim(),
        },

        'description': {'ar': result.fullAr.trim(), 'en': result.fullEn.trim()},

        'technologies': result.tech
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(),

        'imageUrl': result.cover.trim(),

        'galleryImages': result.gallery
            .split('\n')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(),

        'githubUrl': result.github.trim().isEmpty ? null : result.github.trim(),

        'liveUrl': result.demo.trim().isEmpty ? null : result.demo.trim(),

        'featured': result.featured,

        'showOnHome': result.showHome,

        'published': result.active,

        'order': id == null
            ? _projects.length + 1
            : _order(_projects.firstWhere((element) => element.id == id)),
      });

      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save project: $error')));
    }
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> _delete(String id) async {
    try {
      await _repo.deleteDocument(FirestoreCollections.projects, id);

      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete project: $error')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _eyebrowArController.dispose();
    _eyebrowEnController.dispose();

    _titleArController.dispose();
    _titleEnController.dispose();

    _descriptionArController.dispose();
    _descriptionEnController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Projects',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(28),
                children: [
                  // ===========================================================
                  // Projects Section Content
                  // ===========================================================
                  Text(
                    'Projects Section Content',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Section Text',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),

                          const SizedBox(height: 20),

                          // -------------------------------------------------
                          // Eyebrow
                          // -------------------------------------------------
                          TextField(
                            controller: _eyebrowArController,
                            decoration: const InputDecoration(
                              labelText: 'Eyebrow Arabic',
                              hintText: 'المشاريع',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 14),

                          TextField(
                            controller: _eyebrowEnController,
                            decoration: const InputDecoration(
                              labelText: 'Eyebrow English',
                              hintText: 'PROJECTS',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // -------------------------------------------------
                          // Title
                          // -------------------------------------------------
                          TextField(
                            controller: _titleArController,
                            decoration: const InputDecoration(
                              labelText: 'Title Arabic',
                              hintText: 'نماذج مختارة من أعمالي.',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 14),

                          TextField(
                            controller: _titleEnController,
                            decoration: const InputDecoration(
                              labelText: 'Title English',
                              hintText: 'Selected work.',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // -------------------------------------------------
                          // Description
                          // -------------------------------------------------
                          TextField(
                            controller: _descriptionArController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Description Arabic',
                              hintText:
                                  'مجموعة من التطبيقات والمنتجات التي عملت على بنائها.',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 14),

                          TextField(
                            controller: _descriptionEnController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Description English',
                              hintText:
                                  'A collection of applications and products I have built.',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _sectionSaving
                                  ? null
                                  : _saveProjectsSectionContent,
                              icon: _sectionSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                _sectionSaving ? 'Saving...' : 'Save Section',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ===========================================================
                  // Projects
                  // ===========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Projects',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      FilledButton.icon(
                        onPressed: () => _edit(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Project'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  for (final project in _projects)
                    Card(
                      child: ListTile(
                        title: Text(_localized(project.data()['title'], 'en')),
                        subtitle: Text(
                          'Order ${_order(project)} • '
                          '${project.data()['featured'] == true ? 'Featured • ' : ''}'
                          '${project.data()['showOnHome'] == true ? 'Home' : 'Hidden'}',
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _edit(id: project.id, data: project.data()),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              onPressed: () => _delete(project.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

// =============================================================================
// Project Form Result
// =============================================================================

class _ProjectFormResult {
  const _ProjectFormResult({
    required this.titleAr,
    required this.titleEn,
    required this.shortAr,
    required this.shortEn,
    required this.fullAr,
    required this.fullEn,
    required this.tech,
    required this.cover,
    required this.gallery,
    required this.github,
    required this.demo,
    required this.featured,
    required this.showHome,
    required this.active,
  });

  final String titleAr;
  final String titleEn;

  final String shortAr;
  final String shortEn;

  final String fullAr;
  final String fullEn;

  final String tech;
  final String cover;
  final String gallery;

  final String github;
  final String demo;

  final bool featured;
  final bool showHome;
  final bool active;
}

// =============================================================================
// Project Editor Dialog
// =============================================================================

class _ProjectEditorDialog extends StatefulWidget {
  const _ProjectEditorDialog({required this.id, required this.data});

  final String? id;
  final Map<String, dynamic>? data;

  @override
  State<_ProjectEditorDialog> createState() => _ProjectEditorDialogState();
}

class _ProjectEditorDialogState extends State<_ProjectEditorDialog> {
  late final TextEditingController _titleAr;
  late final TextEditingController _titleEn;

  late final TextEditingController _shortAr;
  late final TextEditingController _shortEn;

  late final TextEditingController _fullAr;
  late final TextEditingController _fullEn;

  late final TextEditingController _tech;
  late final TextEditingController _cover;
  late final TextEditingController _gallery;

  late final TextEditingController _github;
  late final TextEditingController _demo;

  late bool _featured;
  late bool _showHome;
  late bool _active;

  @override
  void initState() {
    super.initState();

    final data = widget.data;

    _titleAr = TextEditingController(
      text: _localizedValue(data?['title'], 'ar'),
    );

    _titleEn = TextEditingController(
      text: _localizedValue(data?['title'], 'en'),
    );

    _shortAr = TextEditingController(
      text: _localizedValue(data?['shortDescription'], 'ar'),
    );

    _shortEn = TextEditingController(
      text: _localizedValue(data?['shortDescription'], 'en'),
    );

    _fullAr = TextEditingController(
      text: _localizedValue(data?['description'], 'ar'),
    );

    _fullEn = TextEditingController(
      text: _localizedValue(data?['description'], 'en'),
    );

    _tech = TextEditingController(
      text: data?['technologies'] is List
          ? (data!['technologies'] as List).join(', ')
          : '',
    );

    _cover = TextEditingController(text: data?['imageUrl']?.toString() ?? '');

    _gallery = TextEditingController(
      text: data?['galleryImages'] is List
          ? (data!['galleryImages'] as List).join('\n')
          : '',
    );

    _github = TextEditingController(text: data?['githubUrl']?.toString() ?? '');

    _demo = TextEditingController(text: data?['liveUrl']?.toString() ?? '');

    _featured = data?['featured'] == true;

    _showHome = data?['showOnHome'] is bool
        ? data!['showOnHome'] as bool
        : true;

    _active = data?['published'] is bool ? data!['published'] as bool : true;
  }

  String _localizedValue(Object? value, String language) {
    return value is Map ? value[language]?.toString() ?? '' : '';
  }

  // ---------------------------------------------------------------------------
  // Field
  // ---------------------------------------------------------------------------

  Widget _field(
    TextEditingController controller,
    String label, {
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  void _save() {
    Navigator.of(context).pop(
      _ProjectFormResult(
        titleAr: _titleAr.text,
        titleEn: _titleEn.text,
        shortAr: _shortAr.text,
        shortEn: _shortEn.text,
        fullAr: _fullAr.text,
        fullEn: _fullEn.text,
        tech: _tech.text,
        cover: _cover.text,
        gallery: _gallery.text,
        github: _github.text,
        demo: _demo.text,
        featured: _featured,
        showHome: _showHome,
        active: _active,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _titleAr.dispose();
    _titleEn.dispose();

    _shortAr.dispose();
    _shortEn.dispose();

    _fullAr.dispose();
    _fullEn.dispose();

    _tech.dispose();
    _cover.dispose();
    _gallery.dispose();

    _github.dispose();
    _demo.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final dialogWidth = screenWidth - 48 < 620 ? screenWidth - 48 : 620.0;

    return AlertDialog(
      title: Text(widget.id == null ? 'Add Project' : 'Edit Project'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_titleAr, 'Name Arabic'),

              _field(_titleEn, 'Name English'),

              _field(_shortAr, 'Short Description Arabic', lines: 3),

              _field(_shortEn, 'Short Description English', lines: 3),

              _field(_fullAr, 'Full Description Arabic', lines: 5),

              _field(_fullEn, 'Full Description English', lines: 5),

              _field(_tech, 'Technologies (comma separated)'),

              _field(_cover, 'Cover image asset path'),

              _field(
                _gallery,
                'Gallery image asset paths (one per line)',
                lines: 4,
              ),

              _field(_github, 'GitHub URL'),

              _field(_demo, 'Demo URL'),

              SwitchListTile(
                title: const Text('Featured'),
                value: _featured,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() {
                    _featured = value;
                  });
                },
              ),

              SwitchListTile(
                title: const Text('Show in Home'),
                value: _showHome,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() {
                    _showHome = value;
                  });
                },
              ),

              SwitchListTile(
                title: const Text('Active / Published'),
                value: _active,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() {
                    _active = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
