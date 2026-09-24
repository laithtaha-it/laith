import 'package:flutter/material.dart';

import '../../data/repositories/cv_repository_impl.dart';
import '../../domain/entities/cv_section.dart';
import '../../domain/repositories/cv_repository.dart';
import '../widgets/cv_section_dialog.dart';
import 'cv_section_editor_page.dart';
import '../../../admin/presentation/widgets/admin_scaffold.dart';

class AdminCvPage extends StatefulWidget {
  const AdminCvPage({super.key});

  @override
  State<AdminCvPage> createState() => _AdminCvPageState();
}

class _AdminCvPageState extends State<AdminCvPage> {
  final CvRepository _repository = CvRepositoryImpl();

  bool _loading = true;
  List<CvSection> _sections = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sections = await _repository.getSections();
      if (!mounted) return;
      setState(() {
        _sections = sections;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('Failed to load CV sections: $error');
    }
  }

  Future<void> _addSection() async {
    final result = await showDialog<CvSection>(
      context: context,
      builder: (_) => CvSectionDialog(nextOrder: _sections.length),
    );
    if (result == null) return;

    await _repository.saveSection(result);
    await _load();
    if (!mounted) return;
    _message('Section added successfully.');
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CvSectionEditorPage(section: result)),
    );
    await _load();
  }

  Future<void> _editSection(CvSection section) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CvSectionEditorPage(section: section)),
    );
    await _load();
  }

  Future<void> _deleteSection(CvSection section) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete section?'),
        content: Text('Delete "${section.titleEn}" from the CV?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _repository.deleteSection(section.id);
    await _load();
    if (mounted) _message('Section deleted.');
  }

  Future<void> _move(int oldIndex, int newIndex) async {
    if (newIndex < 0 || newIndex >= _sections.length) return;

    final updated = List<CvSection>.from(_sections);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    setState(() {
      _sections = [
        for (var i = 0; i < updated.length; i++)
          CvSection(
            id: updated[i].id,
            type: updated[i].type,
            titleAr: updated[i].titleAr,
            titleEn: updated[i].titleEn,
            visible: updated[i].visible,
            order: i,
            data: updated[i].data,
          ),
      ];
    });

    try {
      await _repository.reorderSections(_sections);
    } catch (error) {
      if (mounted) _message('Failed to reorder sections: $error');
      await _load();
    }
  }

  Future<void> _toggleVisibility(CvSection section) async {
    final updated = CvSection(
      id: section.id,
      type: section.type,
      titleAr: section.titleAr,
      titleEn: section.titleEn,
      visible: !section.visible,
      order: section.order,
      data: section.data,
    );
    await _repository.saveSection(updated);
    await _load();
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'CV',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(32),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CV Content Manager',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Manage independent CV sections. Add, hide, edit, delete, and reorder them without changing the existing portfolio content.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: _addSection,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Section'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  if (_sections.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(Icons.description_outlined, size: 48),
                            const SizedBox(height: 12),
                            const Text('No CV sections yet.'),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _addSection,
                              icon: const Icon(Icons.add),
                              label: const Text('Create first section'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._sections.asMap().entries.map(
                      (entry) => _SectionTile(
                        section: entry.value,
                        index: entry.key,
                        count: _sections.length,
                        onEdit: () => _editSection(entry.value),
                        onDelete: () => _deleteSection(entry.value),
                        onToggle: () => _toggleVisibility(entry.value),
                        onMoveUp: () => _move(entry.key, entry.key - 1),
                        onMoveDown: () => _move(entry.key, entry.key + 1),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.section,
    required this.index,
    required this.count,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final CvSection section;
  final int index;
  final int count;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(section.titleEn.isEmpty ? section.titleAr : section.titleEn),
        subtitle: Text('${section.type}  •  ${section.visible ? 'Visible' : 'Hidden'}'),
        trailing: Wrap(
          spacing: 2,
          children: [
            IconButton(
              tooltip: 'Move up',
              onPressed: index == 0 ? null : onMoveUp,
              icon: const Icon(Icons.keyboard_arrow_up),
            ),
            IconButton(
              tooltip: 'Move down',
              onPressed: index == count - 1 ? null : onMoveDown,
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
            IconButton(
              tooltip: section.visible ? 'Hide' : 'Show',
              onPressed: onToggle,
              icon: Icon(section.visible ? Icons.visibility : Icons.visibility_off),
            ),
            IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
