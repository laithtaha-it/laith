import 'package:flutter/material.dart';

import '../../data/repositories/cv_repository_impl.dart';
import '../../domain/entities/cv_section.dart';
import '../../domain/repositories/cv_repository.dart';

class CvSectionEditorPage extends StatefulWidget {
  const CvSectionEditorPage({required this.section, super.key});

  final CvSection section;

  @override
  State<CvSectionEditorPage> createState() => _CvSectionEditorPageState();
}

class _CvSectionEditorPageState extends State<CvSectionEditorPage> {
  final CvRepository _repository = CvRepositoryImpl();

  late CvSection _section;
  late Map<String, dynamic> _data;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _section = widget.section;
    _data = Map<String, dynamic>.from(widget.section.data);
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      final updated = CvSection(
        id: _section.id,
        type: _section.type,
        titleAr: _section.titleAr,
        titleEn: _section.titleEn,
        visible: _section.visible,
        order: _section.order,
        data: _data,
      );

      await _repository.saveSection(updated);

      if (!mounted) return;

      setState(() {
        _section = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CV section saved successfully.')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save section: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _set(String key, Object? value) {
    setState(() {
      _data[key] = value;
    });
  }

  List<Map<String, dynamic>> _items() {
    final raw = _data['items'];

    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  void _setItems(List<Map<String, dynamic>> items) {
    _set('items', items);
  }

  Future<void> _editItem({
    Map<String, dynamic>? item,
    required int index,
  }) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _ItemEditorDialog(type: _section.type, item: item),
    );

    if (result == null) return;

    final items = _items();

    if (index >= 0 && index < items.length) {
      items[index] = result;
    } else {
      items.add(result);
    }

    _setItems(items);
  }

  void _removeItem(int index) {
    final items = _items();

    if (index < 0 || index >= items.length) {
      return;
    }

    items.removeAt(index);
    _setItems(items);
  }

  void _moveItem(int index, int direction) {
    final items = _items();

    final target = index + direction;

    if (target < 0 || target >= items.length) {
      return;
    }

    final item = items.removeAt(index);
    items.insert(target, item);

    _setItems(items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _section.titleEn.isEmpty ? _section.titleAr : _section.titleEn,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _buildEditor(),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    switch (_section.type) {
      case 'profile':
        return _ProfileEditor(data: _data, onChanged: _set);

      case 'summary':
        return _SummaryEditor(data: _data, onChanged: _set);

      case 'skills':
        return _SkillsEditor(items: _items(), onChanged: _setItems);

      case 'experience':
      case 'education':
      case 'projects':
      case 'certifications':
      case 'languages':
        return _ListSectionEditor(
          type: _section.type,
          items: _items(),
          onAdd: () => _editItem(index: -1),
          onEdit: (index) => _editItem(item: _items()[index], index: index),
          onDelete: _removeItem,
          onMoveUp: (index) => _moveItem(index, -1),
          onMoveDown: (index) => _moveItem(index, 1),
        );

      default:
        return _CustomEditor(data: _data, onChanged: _set);
    }
  }
}

class _ProfileEditor extends StatelessWidget {
  const _ProfileEditor({required this.data, required this.onChanged});

  final Map<String, dynamic> data;
  final void Function(String, Object?) onChanged;

  @override
  Widget build(BuildContext context) {
    return _EditorCard(
      title: 'Personal Information',
      subtitle: 'This information belongs only to the CV.',
      children: [
        _field('Full name', 'name', data, onChanged),
        _field('Professional title / role', 'role', data, onChanged),
        _field('Email', 'email', data, onChanged),
        _field('Phone', 'phone', data, onChanged),
        _field('Location', 'location', data, onChanged),
        _field('Website', 'website', data, onChanged),
        _field('GitHub', 'github', data, onChanged),
        _field('LinkedIn', 'linkedin', data, onChanged),
        _field('Profile image URL', 'imageUrl', data, onChanged),
      ],
    );
  }
}

class _SummaryEditor extends StatelessWidget {
  const _SummaryEditor({required this.data, required this.onChanged});

  final Map<String, dynamic> data;
  final void Function(String, Object?) onChanged;

  @override
  Widget build(BuildContext context) {
    return _EditorCard(
      title: 'Professional Summary',
      subtitle: 'Write the summary independently in Arabic and English.',
      children: [
        _field('Arabic summary', 'contentAr', data, onChanged, maxLines: 7),
        _field('English summary', 'contentEn', data, onChanged, maxLines: 7),
      ],
    );
  }
}

class _CustomEditor extends StatelessWidget {
  const _CustomEditor({required this.data, required this.onChanged});

  final Map<String, dynamic> data;
  final void Function(String, Object?) onChanged;

  @override
  Widget build(BuildContext context) {
    return _EditorCard(
      title: 'Custom Section',
      subtitle: 'A flexible text area for sections you create in the future.',
      children: [
        _field('Arabic content', 'contentAr', data, onChanged, maxLines: 8),
        _field('English content', 'contentEn', data, onChanged, maxLines: 8),
      ],
    );
  }
}

class _ListSectionEditor extends StatelessWidget {
  const _ListSectionEditor({
    required this.type,
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final String type;
  final List<Map<String, dynamic>> items;

  final VoidCallback onAdd;
  final void Function(int index) onEdit;
  final void Function(int index) onDelete;
  final void Function(int index) onMoveUp;
  final void Function(int index) onMoveDown;

  String get _label => switch (type) {
    'experience' => 'Experience',
    'education' => 'Education',
    'projects' => 'CV Projects',
    'certifications' => 'Certifications',
    'languages' => 'Languages',
    _ => 'Items',
  };

  String _title(Map<String, dynamic> item) {
    final value =
        item['titleEn'] ??
        item['nameEn'] ??
        item['name'] ??
        item['degreeEn'] ??
        item['company'];

    return value?.toString().trim().isNotEmpty == true
        ? value.toString()
        : 'Untitled item';
  }

  String _subtitle(Map<String, dynamic> item) {
    final value =
        item['company'] ??
        item['issuer'] ??
        item['institution'] ??
        item['levelEn'] ??
        item['category'];

    return value?.toString() ?? '';
  }

  String _period(Map<String, dynamic> item) {
    final start = item['startDate']?.toString().trim() ?? '';

    final end = item['current'] == true
        ? 'Present'
        : (item['endDate']?.toString().trim() ?? '');

    if (start.isEmpty && end.isEmpty) {
      return '';
    }

    if (start.isEmpty) {
      return end;
    }

    if (end.isEmpty) {
      return start;
    }

    return '$start – $end';
  }

  int _bulletCount(Map<String, dynamic> item) {
    final raw = item['bulletsEn'];

    if (raw is List) {
      return raw.where((e) => e.toString().trim().isNotEmpty).length;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return _EditorCard(
      title: _label,
      subtitle:
          'Add, edit, and remove CV-specific entries. These are separate from your portfolio data.',
      trailing: FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      children: [
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('No items yet. Add the first one.')),
          )
        else
          for (var index = 0; index < items.length; index++)
            _CvEntryCard(
              type: type,
              index: index,
              count: items.length,
              item: items[index],
              title: _title(items[index]),
              subtitle: _subtitle(items[index]),
              period: _period(items[index]),
              bulletCount: _bulletCount(items[index]),
              onEdit: () => onEdit(index),
              onDelete: () => onDelete(index),
              onMoveUp: () => onMoveUp(index),
              onMoveDown: () => onMoveDown(index),
            ),
      ],
    );
  }
}

class _CvEntryCard extends StatelessWidget {
  const _CvEntryCard({
    required this.type,
    required this.index,
    required this.count,
    required this.item,
    required this.title,
    required this.subtitle,
    required this.period,
    required this.bulletCount,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final String type;
  final int index;
  final int count;

  final Map<String, dynamic> item;

  final String title;
  final String subtitle;
  final String period;
  final int bulletCount;

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    final isRich = type == 'experience' || type == 'projects';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Text('${index + 1}')),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (period.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(period, style: Theme.of(context).textTheme.bodySmall),
                  ],
                  if (isRich) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(
                          avatar: const Icon(
                            Icons.format_list_bulleted,
                            size: 16,
                          ),
                          label: Text('$bulletCount bullets'),
                          visualDensity: VisualDensity.compact,
                        ),
                        if (type == 'projects' &&
                            (item['technologies']
                                    ?.toString()
                                    .trim()
                                    .isNotEmpty ??
                                false))
                          Chip(
                            avatar: const Icon(Icons.code, size: 16),
                            label: Text(item['technologies'].toString()),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
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
              ],
            ),
            Column(
              children: [
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
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               SKILLS EDITOR                                */
/* -------------------------------------------------------------------------- */

class _SkillsEditor extends StatefulWidget {
  const _SkillsEditor({required this.items, required this.onChanged});

  final List<Map<String, dynamic>> items;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  @override
  State<_SkillsEditor> createState() => _SkillsEditorState();
}

class _SkillsEditorState extends State<_SkillsEditor> {
  late List<_SkillCategory> _categories;

  @override
  void initState() {
    super.initState();

    _categories = _groupItems(widget.items);
  }

  List<_SkillCategory> _groupItems(List<Map<String, dynamic>> items) {
    final categories = <_SkillCategory>[];

    for (final item in items) {
      /*
       * Supports both the new schema:
       *
       * categoryEn
       * categoryAr
       *
       * and the old schema:
       *
       * category
       *
       * This allows existing CV Skills data to continue
       * working without being lost.
       */

      final categoryEn =
          item['categoryEn']?.toString().trim().isNotEmpty == true
          ? item['categoryEn'].toString().trim()
          : item['category']?.toString().trim() ?? '';

      final categoryAr = item['categoryAr']?.toString().trim() ?? '';

      final categoryKey =
          '${categoryEn.toLowerCase()}|${categoryAr.toLowerCase()}';

      final skill = _CvSkill(
        nameEn: item['nameEn']?.toString() ?? '',
        nameAr: item['nameAr']?.toString() ?? '',
      );

      final existingIndex = categories.indexWhere(
        (category) => category.key == categoryKey,
      );

      if (existingIndex == -1) {
        categories.add(
          _SkillCategory(
            categoryEn: categoryEn,
            categoryAr: categoryAr,
            skills: [skill],
          ),
        );
      } else {
        categories[existingIndex].skills.add(skill);
      }
    }

    return categories;
  }

  List<Map<String, dynamic>> _flatten() {
    final result = <Map<String, dynamic>>[];

    for (final category in _categories) {
      for (final skill in category.skills) {
        result.add({
          'nameEn': skill.nameEn,
          'nameAr': skill.nameAr,
          'categoryEn': category.categoryEn,
          'categoryAr': category.categoryAr,
        });
      }
    }

    return result;
  }

  void _notify() {
    widget.onChanged(_flatten());
  }

  Future<void> _addCategory() async {
    final result = await showDialog<_SkillCategory>(
      context: context,
      builder: (_) => const _SkillCategoryDialog(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _categories.add(result);
    });

    _notify();
  }

  Future<void> _editCategory(int index) async {
    final category = _categories[index];

    final result = await showDialog<_SkillCategory>(
      context: context,
      builder: (_) => _SkillCategoryDialog(category: category),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _categories[index] = result;
    });

    _notify();
  }

  void _deleteCategory(int index) {
    final category = _categories[index];

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'This will delete "${category.categoryEn}" '
          'and all skills inside it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _categories.removeAt(index);
              });

              _notify();

              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _moveCategory(int index, int direction) {
    final target = index + direction;

    if (target < 0 || target >= _categories.length) {
      return;
    }

    setState(() {
      final category = _categories.removeAt(index);

      _categories.insert(target, category);
    });

    _notify();
  }

  Future<void> _addSkill(int categoryIndex) async {
    final result = await showDialog<_CvSkill>(
      context: context,
      builder: (_) => const _SkillDialog(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _categories[categoryIndex].skills.add(result);
    });

    _notify();
  }

  Future<void> _editSkill(int categoryIndex, int skillIndex) async {
    final skill = _categories[categoryIndex].skills[skillIndex];

    final result = await showDialog<_CvSkill>(
      context: context,
      builder: (_) => _SkillDialog(skill: skill),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _categories[categoryIndex].skills[skillIndex] = result;
    });

    _notify();
  }

  void _deleteSkill(int categoryIndex, int skillIndex) {
    setState(() {
      _categories[categoryIndex].skills.removeAt(skillIndex);

      /*
       * If the last skill in a category is removed,
       * keep the category itself.
       *
       * This is intentional because an empty category
       * can still be edited and receive new skills.
       */
    });

    _notify();
  }

  void _moveSkill(int categoryIndex, int skillIndex, int direction) {
    final skills = _categories[categoryIndex].skills;

    final target = skillIndex + direction;

    if (target < 0 || target >= skills.length) {
      return;
    }

    setState(() {
      final skill = skills.removeAt(skillIndex);

      skills.insert(target, skill);
    });

    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return _EditorCard(
      title: 'Technical Skills',
      subtitle:
          'Organize your CV skills by category. These skills are completely independent from your portfolio Skills section.',
      trailing: FilledButton.icon(
        onPressed: _addCategory,
        icon: const Icon(Icons.add),
        label: const Text('Add category'),
      ),
      children: [
        if (_categories.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'No skill categories yet. '
                'Add your first category.',
              ),
            ),
          )
        else
          for (
            var categoryIndex = 0;
            categoryIndex < _categories.length;
            categoryIndex++
          )
            _SkillCategoryCard(
              category: _categories[categoryIndex],
              index: categoryIndex,
              count: _categories.length,
              onEdit: () => _editCategory(categoryIndex),
              onDelete: () => _deleteCategory(categoryIndex),
              onMoveUp: () => _moveCategory(categoryIndex, -1),
              onMoveDown: () => _moveCategory(categoryIndex, 1),
              onAddSkill: () => _addSkill(categoryIndex),
              onEditSkill: (skillIndex) =>
                  _editSkill(categoryIndex, skillIndex),
              onDeleteSkill: (skillIndex) =>
                  _deleteSkill(categoryIndex, skillIndex),
              onMoveSkillUp: (skillIndex) =>
                  _moveSkill(categoryIndex, skillIndex, -1),
              onMoveSkillDown: (skillIndex) =>
                  _moveSkill(categoryIndex, skillIndex, 1),
            ),
      ],
    );
  }
}

class _SkillCategory {
  _SkillCategory({
    required this.categoryEn,
    required this.categoryAr,
    required this.skills,
  });

  String categoryEn;
  String categoryAr;
  List<_CvSkill> skills;

  String get key =>
      '${categoryEn.toLowerCase()}|'
      '${categoryAr.toLowerCase()}';
}

class _CvSkill {
  _CvSkill({required this.nameEn, required this.nameAr});

  String nameEn;
  String nameAr;
}

class _SkillCategoryCard extends StatelessWidget {
  const _SkillCategoryCard({
    required this.category,
    required this.index,
    required this.count,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onAddSkill,
    required this.onEditSkill,
    required this.onDeleteSkill,
    required this.onMoveSkillUp,
    required this.onMoveSkillDown,
  });

  final _SkillCategory category;

  final int index;
  final int count;

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onAddSkill;

  final ValueChanged<int> onEditSkill;
  final ValueChanged<int> onDeleteSkill;
  final ValueChanged<int> onMoveSkillUp;
  final ValueChanged<int> onMoveSkillDown;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(child: Text('${index + 1}')),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.categoryEn.isEmpty
                            ? 'Untitled category'
                            : category.categoryEn,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (category.categoryAr.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          category.categoryAr,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ],
                  ),
                ),
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
                  tooltip: 'Edit category',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete category',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const Divider(height: 28),
            if (category.skills.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No skills in this category.'),
              )
            else
              for (
                var skillIndex = 0;
                skillIndex < category.skills.length;
                skillIndex++
              )
                _SkillRowEditor(
                  skill: category.skills[skillIndex],
                  index: skillIndex,
                  count: category.skills.length,
                  onEdit: () => onEditSkill(skillIndex),
                  onDelete: () => onDeleteSkill(skillIndex),
                  onMoveUp: () => onMoveSkillUp(skillIndex),
                  onMoveDown: () => onMoveSkillDown(skillIndex),
                ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onAddSkill,
                icon: const Icon(Icons.add),
                label: const Text('Add skill'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillRowEditor extends StatelessWidget {
  const _SkillRowEditor({
    required this.skill,
    required this.index,
    required this.count,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final _CvSkill skill;

  final int index;
  final int count;

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: .35),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.drag_indicator),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                skill.nameEn.isEmpty ? 'Unnamed skill' : skill.nameEn,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (skill.nameAr.isNotEmpty)
              Expanded(
                child: Text(
                  skill.nameAr,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
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
              tooltip: 'Edit skill',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete skill',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                         SKILL CATEGORY DIALOG                              */
/* -------------------------------------------------------------------------- */

class _SkillCategoryDialog extends StatefulWidget {
  const _SkillCategoryDialog({this.category});

  final _SkillCategory? category;

  @override
  State<_SkillCategoryDialog> createState() => _SkillCategoryDialogState();
}

class _SkillCategoryDialogState extends State<_SkillCategoryDialog> {
  late final TextEditingController _enController;

  late final TextEditingController _arController;

  @override
  void initState() {
    super.initState();

    _enController = TextEditingController(
      text: widget.category?.categoryEn ?? '',
    );

    _arController = TextEditingController(
      text: widget.category?.categoryAr ?? '',
    );
  }

  @override
  void dispose() {
    _enController.dispose();
    _arController.dispose();

    super.dispose();
  }

  void _save() {
    final en = _enController.text.trim();

    final ar = _arController.text.trim();

    if (en.isEmpty && ar.isEmpty) {
      return;
    }

    final existingSkills =
        widget.category?.skills
            .map(
              (skill) => _CvSkill(nameEn: skill.nameEn, nameAr: skill.nameAr),
            )
            .toList() ??
        <_CvSkill>[];

    Navigator.pop(
      context,
      _SkillCategory(categoryEn: en, categoryAr: ar, skills: existingSkills),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.category != null;

    return AlertDialog(
      title: Text(editing ? 'Edit skill category' : 'Add skill category'),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width - 48 < 650
          ? MediaQuery.sizeOf(context).width - 48
          : 650,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _enController,
              decoration: const InputDecoration(
                labelText: 'Category name (English)',
                hintText: 'Mobile Development',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _arController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'اسم التصنيف (العربي)',
                hintText: 'تطوير تطبيقات الهاتف',
                border: OutlineInputBorder(),
              ),
            ),
            if (!editing) ...[
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'After creating the category, '
                  'use “Add skill” to add its skills.',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(editing ? 'Save changes' : 'Add category'),
        ),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              SKILL DIALOG                                  */
/* -------------------------------------------------------------------------- */

class _SkillDialog extends StatefulWidget {
  const _SkillDialog({this.skill});

  final _CvSkill? skill;

  @override
  State<_SkillDialog> createState() => _SkillDialogState();
}

class _SkillDialogState extends State<_SkillDialog> {
  late final TextEditingController _enController;

  late final TextEditingController _arController;

  @override
  void initState() {
    super.initState();

    _enController = TextEditingController(text: widget.skill?.nameEn ?? '');

    _arController = TextEditingController(text: widget.skill?.nameAr ?? '');
  }

  @override
  void dispose() {
    _enController.dispose();
    _arController.dispose();

    super.dispose();
  }

  void _save() {
    final en = _enController.text.trim();

    final ar = _arController.text.trim();

    if (en.isEmpty && ar.isEmpty) {
      return;
    }

    Navigator.pop(context, _CvSkill(nameEn: en, nameAr: ar));
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.skill != null;

    return AlertDialog(
      title: Text(editing ? 'Edit skill' : 'Add skill'),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width - 48 < 650
          ? MediaQuery.sizeOf(context).width - 48
          : 650,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _enController,
              decoration: const InputDecoration(
                labelText: 'Skill name (English)',
                hintText: 'Flutter',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _arController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'اسم المهارة (العربي)',
                hintText: 'Flutter',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(editing ? 'Save changes' : 'Add skill'),
        ),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              EDITOR CARD                                   */
/* -------------------------------------------------------------------------- */

class _EditorCard extends StatelessWidget {
  const _EditorCard({
    required this.title,
    required this.subtitle,
    required this.children,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(subtitle),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 16), trailing!],
              ],
            ),
            const SizedBox(height: 24),
            ..._withSpacing(children),
          ],
        ),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets) {
    final result = <Widget>[];

    for (var i = 0; i < widgets.length; i++) {
      if (i > 0) {
        result.add(const SizedBox(height: 14));
      }

      result.add(widgets[i]);
    }

    return result;
  }
}

/* -------------------------------------------------------------------------- */
/*                                  FIELD                                     */
/* -------------------------------------------------------------------------- */

Widget _field(
  String label,
  String key,
  Map<String, dynamic> data,
  void Function(String, Object?) onChanged, {
  int maxLines = 1,
}) {
  return TextFormField(
    initialValue: data[key]?.toString() ?? '',
    maxLines: maxLines,
    onChanged: (value) => onChanged(key, value),
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      alignLabelWithHint: maxLines > 1,
    ),
  );
}

/* -------------------------------------------------------------------------- */
/*                              ITEM DIALOG                                   */
/* -------------------------------------------------------------------------- */

class _ItemEditorDialog extends StatefulWidget {
  const _ItemEditorDialog({required this.type, this.item});

  final String type;
  final Map<String, dynamic>? item;

  @override
  State<_ItemEditorDialog> createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<_ItemEditorDialog> {
  late final Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();

    _data = Map<String, dynamic>.from(widget.item ?? {});
  }

  void _set(String key, Object? value) {
    setState(() {
      _data[key] = value;
    });
  }

  Widget _text(
    String label,
    String key, {
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: _data[key]?.toString() ?? '',
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: (value) => _set(key, value),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withSpacing(children),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _fields() {
    switch (widget.type) {
      case 'experience':
        return [
          _SectionHint(
            title: 'Experience entry',
            text:
                'Enter the role exactly as it should appear on the CV. Keep the bullets focused on measurable work, responsibilities, and impact.',
          ),
          _row([
            _text('Job title (English)', 'titleEn', hint: 'Flutter Developer'),
            _text('Job title (Arabic)', 'titleAr', hint: 'مطور Flutter'),
          ]),
          _row([
            _text('Company', 'company', hint: 'Company / Organization'),
            _text('Location', 'location', hint: 'City, Country'),
          ]),
          _row([
            _text('Start date', 'startDate', hint: 'MM/YYYY'),
            _text('End date', 'endDate', hint: 'MM/YYYY'),
          ]),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Current position'),
            subtitle: const Text('Show “Present” instead of the end date.'),
            value: _data['current'] == true,
            onChanged: (value) => _set('current', value),
          ),
          _BulletPointsEditor(data: _data, onChanged: _set),
        ];

      case 'projects':
        return [
          _SectionHint(
            title: 'Project entry',
            text:
                'Build this exactly like a real CV project entry: name, tech stack, concise achievement bullets, and optional links.',
          ),
          _row([
            _text(
              'Project title (English)',
              'titleEn',
              hint: 'Keeply — Secure Vault',
            ),
            _text(
              'Project title (Arabic)',
              'titleAr',
              hint: 'Keeply — خزنة آمنة',
            ),
          ]),
          _text(
            'Technologies / Tech Stack',
            'technologies',
            hint: 'Flutter · Dart · Firebase · Riverpod',
          ),
          _BulletPointsEditor(data: _data, onChanged: _set),
          _row([
            _text('Project URL', 'url', hint: 'https://...'),
            _text('GitHub URL', 'githubUrl', hint: 'https://github.com/...'),
          ]),
          _row([
            _text('Start date', 'startDate', hint: 'MM/YYYY'),
            _text('End date', 'endDate', hint: 'MM/YYYY or Present'),
          ]),
        ];

      case 'education':
        return [
          _row([
            _text('Degree / qualification (English)', 'degreeEn'),
            _text('Degree / qualification (Arabic)', 'degreeAr'),
          ]),
          _row([
            _text('Institution', 'institution'),
            _text('Location', 'location'),
          ]),
          _row([
            _text('Start date', 'startDate'),
            _text('End date', 'endDate'),
          ]),
          _text('Description (English)', 'descriptionEn', maxLines: 4),
          _text('Description (Arabic)', 'descriptionAr', maxLines: 4),
        ];

      case 'certifications':
        return [
          _row([
            _text('Certificate / Award name (English)', 'nameEn'),
            _text('Certificate / Award name (Arabic)', 'nameAr'),
          ]),
          _row([
            _text('Issuer (English)', 'issuerEn'),
            _text('Issuer (Arabic)', 'issuerAr'),
          ]),
          _row([
            _text('Issue date', 'date', hint: 'MM/YYYY'),
            _text('Certificate URL', 'url', hint: 'https://...'),
          ]),
        ];

      case 'languages':
        return [
          _row([
            _text('Language (English)', 'nameEn'),
            _text('Language (Arabic)', 'nameAr'),
          ]),
          _row([
            _text(
              'Level (English)',
              'levelEn',
              hint: 'Native / Fluent / Professional',
            ),
            _text('Level (Arabic)', 'levelAr'),
          ]),
        ];

      default:
        return [
          _row([
            _text('Title (English)', 'titleEn'),
            _text('Title (Arabic)', 'titleAr'),
          ]),
          _text('Content (English)', 'contentEn', maxLines: 6),
          _text('Content (Arabic)', 'contentAr', maxLines: 6),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.item != null;

    return AlertDialog(
      title: Text(
        '${editing ? 'Edit' : 'Add'} '
        '${widget.type} entry',
      ),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width - 48 < 900
          ? MediaQuery.sizeOf(context).width - 48
          : 900,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withSpacing(_fields()),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, _data),
          icon: const Icon(Icons.check),
          label: Text(editing ? 'Save changes' : 'Add to CV'),
        ),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                           BULLET POINT EDITOR                              */
/* -------------------------------------------------------------------------- */

class _BulletPointsEditor extends StatefulWidget {
  const _BulletPointsEditor({required this.data, required this.onChanged});

  final Map<String, dynamic> data;
  final void Function(String, Object?) onChanged;

  @override
  State<_BulletPointsEditor> createState() => _BulletPointsEditorState();
}

class _BulletPointsEditorState extends State<_BulletPointsEditor> {
  late List<String> _en;
  late List<String> _ar;

  @override
  void initState() {
    super.initState();

    _en = _read('bulletsEn');
    _ar = _read('bulletsAr');

    final max = _en.length > _ar.length ? _en.length : _ar.length;

    while (_en.length < max) {
      _en.add('');
    }

    while (_ar.length < max) {
      _ar.add('');
    }
  }

  List<String> _read(String key) {
    final raw = widget.data[key];

    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }

    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split(RegExp(r'\r?\n'))
          .map((e) => e.replaceFirst(RegExp(r'^\s*[-•*]\s*'), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  void _sync() {
    widget.onChanged('bulletsEn', List<String>.from(_en));

    widget.onChanged('bulletsAr', List<String>.from(_ar));
  }

  void _add() {
    setState(() {
      _en.add('');
      _ar.add('');
    });

    _sync();
  }

  void _remove(int index) {
    setState(() {
      _en.removeAt(index);
      _ar.removeAt(index);
    });

    _sync();
  }

  void _move(int index, int direction) {
    final target = index + direction;

    if (target < 0 || target >= _en.length) {
      return;
    }

    setState(() {
      final en = _en.removeAt(index);

      final ar = _ar.removeAt(index);

      _en.insert(target, en);

      _ar.insert(target, ar);
    });

    _sync();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: .35),
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.format_list_bulleted),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'CV Bullet Points',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'One row = one bullet. '
                      'Keep each point concise '
                      'and achievement-focused.',
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: const Text('Add bullet'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_en.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No bullets yet. '
                  'Add your first bullet point.',
                ),
              ),
            )
          else
            for (var i = 0; i < _en.length; i++)
              _BulletRow(
                index: i,
                en: _en[i],
                ar: _ar[i],
                isFirst: i == 0,
                isLast: i == _en.length - 1,
                onEnChanged: (value) {
                  _en[i] = value;
                  _sync();
                },
                onArChanged: (value) {
                  _ar[i] = value;
                  _sync();
                },
                onUp: () => _move(i, -1),
                onDown: () => _move(i, 1),
                onDelete: () => _remove(i),
              ),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({
    required this.index,
    required this.en,
    required this.ar,
    required this.isFirst,
    required this.isLast,
    required this.onEnChanged,
    required this.onArChanged,
    required this.onUp,
    required this.onDown,
    required this.onDelete,
  });

  final int index;

  final String en;
  final String ar;

  final bool isFirst;
  final bool isLast;

  final ValueChanged<String> onEnChanged;

  final ValueChanged<String> onArChanged;

  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final controls = Column(
      children: [
        IconButton(
          tooltip: 'Move up',
          onPressed: isFirst ? null : onUp,
          icon: const Icon(Icons.keyboard_arrow_up),
        ),
        IconButton(
          tooltip: 'Move down',
          onPressed: isLast ? null : onDown,
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        IconButton(
          tooltip: 'Delete bullet',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fields = [
            Expanded(
              child: TextFormField(
                initialValue: en,
                maxLines: 3,
                onChanged: onEnChanged,
                decoration: InputDecoration(
                  labelText: 'Bullet ${index + 1} — English',
                  hintText:
                      'e.g. Developed a responsive Flutter application...',
                  prefixText: '• ',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: ar,
                maxLines: 3,
                textDirection: TextDirection.rtl,
                onChanged: onArChanged,
                decoration: InputDecoration(
                  labelText: 'النقطة ${index + 1} — عربي',
                  hintText: 'مثال: طورت تطبيقًا متجاوبًا باستخدام Flutter...',
                  prefixText: '• ',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ];

          if (constraints.maxWidth < 760) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      fields[0],
                      const SizedBox(height: 10),
                      fields[1],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                controls,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fields[0],
              const SizedBox(width: 10),
              fields[1],
              const SizedBox(width: 4),
              controls,
            ],
          );
        },
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              SECTION HINT                                  */
/* -------------------------------------------------------------------------- */

class _SectionHint extends StatelessWidget {
  const _SectionHint({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              SPACING HELPER                                */
/* -------------------------------------------------------------------------- */

List<Widget> _withSpacing(List<Widget> widgets) {
  final result = <Widget>[];

  for (var i = 0; i < widgets.length; i++) {
    if (i > 0) {
      result.add(const SizedBox(height: 12));
    }

    result.add(widgets[i]);
  }

  return result;
}
