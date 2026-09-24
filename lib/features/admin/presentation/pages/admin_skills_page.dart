import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/admin_content_repository.dart';
import '../widgets/admin_scaffold.dart';

class AdminSkillsPage extends StatefulWidget {
  const AdminSkillsPage({super.key});

  @override
  State<AdminSkillsPage> createState() => _AdminSkillsPageState();
}

class _AdminSkillsPageState extends State<AdminSkillsPage> {
  final _repo = AdminContentRepository();

  bool _loading = true;
  bool _sectionSaving = false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _categories = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _skills = [];

  // ---------------------------------------------------------------------------
  // Skills Section Content
  // ---------------------------------------------------------------------------

  final _titleArController = TextEditingController();
  final _titleEnController = TextEditingController();

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
        _repo.getCollection(FirestoreCollections.skillCategories),
        _repo.getCollection(FirestoreCollections.skills),
        FirebaseFirestore.instance
            .collection(FirestoreCollections.siteContent)
            .doc('home')
            .get(),
      ]);

      _categories =
          result[0] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;

      _skills = result[1] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;

      final homeDocument = result[2] as DocumentSnapshot<Map<String, dynamic>>;

      _loadSectionContent(homeDocument.data());

      _categories.sort((a, b) => _order(a).compareTo(_order(b)));

      _skills.sort((a, b) => _order(a).compareTo(_order(b)));

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load Skills data: $error')),
        );
      }
    }
  }

  void _loadSectionContent(Map<String, dynamic>? homeData) {
    final skillsData = homeData?['skills'];

    if (skillsData is! Map) {
      return;
    }

    _titleArController.text = skillsData['titleAr']?.toString() ?? '';

    _titleEnController.text = skillsData['titleEn']?.toString() ?? '';
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int _order(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    return (document.data()['order'] as num?)?.toInt() ?? 0;
  }

  String _name(Map<String, dynamic> data) {
    final value = data['name'];

    if (value is Map) {
      return value['en']?.toString() ?? value['ar']?.toString() ?? '';
    }

    return '';
  }

  String _localized(Object? value, String lang) {
    if (value is Map) {
      return value[lang]?.toString() ?? '';
    }

    return '';
  }

  String _slug(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  // ---------------------------------------------------------------------------
  // Save Skills Section Content
  // ---------------------------------------------------------------------------

  Future<void> _saveSkillsSectionContent() async {
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
            'skills': {
              'titleAr': _titleArController.text.trim(),
              'titleEn': _titleEnController.text.trim(),
            },
          }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skills section content saved successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save Skills section: $error')),
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
  // Category Dialog
  // ---------------------------------------------------------------------------

  Future<void> _categoryDialog({String? id, Map<String, dynamic>? data}) async {
    final ar = TextEditingController(text: _localized(data?['name'], 'ar'));

    final en = TextEditingController(text: _localized(data?['name'], 'en'));

    var showHome = data?['showOnHome'] is bool
        ? data!['showOnHome'] as bool
        : true;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(id == null ? 'Add Category' : 'Edit Category'),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width - 48 < 420
                ? MediaQuery.sizeOf(context).width - 48
                : 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ar,
                  decoration: const InputDecoration(labelText: 'Arabic name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: en,
                  decoration: const InputDecoration(labelText: 'English name'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Show in Home'),
                  value: showHome,
                  onChanged: (value) {
                    setLocal(() {
                      showHome = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != true) {
      ar.dispose();
      en.dispose();
      return;
    }

    final newId = id ?? _slug(en.text.isEmpty ? ar.text : en.text);

    if (newId.isEmpty) {
      ar.dispose();
      en.dispose();
      return;
    }

    await _repo.saveDocument(FirestoreCollections.skillCategories, newId, {
      'name': {'ar': ar.text.trim(), 'en': en.text.trim()},
      'order': id == null
          ? _categories.length + 1
          : _order(_categories.firstWhere((element) => element.id == id)),
      'showOnHome': showHome,
      'isActive': true,
    });

    ar.dispose();
    en.dispose();

    await _load();
  }

  // ---------------------------------------------------------------------------
  // Skill Dialog
  // ---------------------------------------------------------------------------

  Future<void> _skillDialog({String? id, Map<String, dynamic>? data}) async {
    if (_categories.isEmpty) {
      return;
    }

    final ar = TextEditingController(text: _localized(data?['name'], 'ar'));

    final en = TextEditingController(text: _localized(data?['name'], 'en'));

    var categoryId = data?['categoryId']?.toString() ?? _categories.first.id;

    var showHome = data?['showOnHome'] is bool
        ? data!['showOnHome'] as bool
        : true;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(id == null ? 'Add Skill' : 'Edit Skill'),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width - 48 < 420
                ? MediaQuery.sizeOf(context).width - 48
                : 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ar,
                  decoration: const InputDecoration(labelText: 'Arabic name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: en,
                  decoration: const InputDecoration(labelText: 'English name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final category in _categories)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(_name(category.data())),
                      ),
                  ],
                  onChanged: (value) {
                    setLocal(() {
                      categoryId = value ?? categoryId;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Show in Home'),
                  value: showHome,
                  onChanged: (value) {
                    setLocal(() {
                      showHome = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != true) {
      ar.dispose();
      en.dispose();
      return;
    }

    final newId = id ?? _slug(en.text.isEmpty ? ar.text : en.text);

    if (newId.isEmpty) {
      ar.dispose();
      en.dispose();
      return;
    }

    await _repo.saveDocument(FirestoreCollections.skills, newId, {
      'name': {'ar': ar.text.trim(), 'en': en.text.trim()},
      'categoryId': categoryId,
      'order': id == null
          ? _skills.length + 1
          : _order(_skills.firstWhere((element) => element.id == id)),
      'showOnHome': showHome,
      'isActive': true,
    });

    ar.dispose();
    en.dispose();

    await _load();
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> _delete(String collection, String id) async {
    await _repo.deleteDocument(collection, id);

    await _load();
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Skills',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(28),
                children: [
                  // ===========================================================
                  // Skills Section Content
                  // ===========================================================
                  Text(
                    'Skills Section Content',
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
                          // Title Arabic
                          // -------------------------------------------------
                          TextField(
                            controller: _titleArController,
                            decoration: const InputDecoration(
                              labelText: 'Title Arabic',
                              hintText: 'المهارات التقنية',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // -------------------------------------------------
                          // Title English
                          // -------------------------------------------------
                          TextField(
                            controller: _titleEnController,
                            decoration: const InputDecoration(
                              labelText: 'Title English',
                              hintText: 'TECHNICAL SKILLS',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _sectionSaving
                                  ? null
                                  : _saveSkillsSectionContent,
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
                  // Skill Categories
                  // ===========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Skill Categories',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      FilledButton.icon(
                        onPressed: () => _categoryDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Category'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  for (final category in _categories)
                    Card(
                      child: ListTile(
                        title: Text(_name(category.data())),
                        subtitle: Text(
                          'Order ${_order(category)} • '
                          '${category.data()['showOnHome'] == true ? 'Visible on Home' : 'Hidden on Home'}',
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              onPressed: () => _categoryDialog(
                                id: category.id,
                                data: category.data(),
                              ),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              onPressed: () => _delete(
                                FirestoreCollections.skillCategories,
                                category.id,
                              ),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // ===========================================================
                  // Skills
                  // ===========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Skills',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      FilledButton.icon(
                        onPressed: _categories.isEmpty
                            ? null
                            : () => _skillDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Skill'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  for (final skill in _skills)
                    Builder(
                      builder: (context) {
                        final matches = _categories.where(
                          (category) =>
                              category.id == skill.data()['categoryId'],
                        );

                        final category = matches.isEmpty ? null : matches.first;

                        return Card(
                          child: ListTile(
                            title: Text(_name(skill.data())),
                            subtitle: Text(
                              '${category == null ? 'Unassigned' : _name(category.data())} • '
                              'Order ${_order(skill)} • '
                              '${skill.data()['showOnHome'] == true ? 'Home' : 'Hidden'}',
                            ),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  onPressed: () => _skillDialog(
                                    id: skill.id,
                                    data: skill.data(),
                                  ),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  onPressed: () => _delete(
                                    FirestoreCollections.skills,
                                    skill.id,
                                  ),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
