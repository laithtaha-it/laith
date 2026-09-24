import 'package:flutter/material.dart';

import '../../domain/entities/cv_section.dart';

class CvSectionDialog extends StatefulWidget {
  const CvSectionDialog({this.section, required this.nextOrder, super.key});

  final CvSection? section;
  final int nextOrder;

  @override
  State<CvSectionDialog> createState() => _CvSectionDialogState();
}

class _CvSectionDialogState extends State<CvSectionDialog> {
  late final TextEditingController _idController;
  late final TextEditingController _titleArController;
  late final TextEditingController _titleEnController;
  late String _type;

  static const _types = [
    'profile',
    'summary',
    'experience',
    'education',
    'skills',
    'projects',
    'certifications',
    'languages',
    'custom',
  ];

  @override
  void initState() {
    super.initState();
    final section = widget.section;
    _idController = TextEditingController(text: section?.id ?? '');
    _titleArController = TextEditingController(text: section?.titleAr ?? '');
    _titleEnController = TextEditingController(text: section?.titleEn ?? '');
    _type = section?.type ?? 'custom';
  }

  @override
  void dispose() {
    _idController.dispose();
    _titleArController.dispose();
    _titleEnController.dispose();
    super.dispose();
  }

  String _slug(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  void _submit() {
    final existing = widget.section;
    final id = _slug(
      _idController.text.isEmpty ? _titleEnController.text : _idController.text,
    );

    if (id.isEmpty ||
        _titleArController.text.trim().isEmpty &&
            _titleEnController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a section ID and title.')),
      );
      return;
    }

    Navigator.pop(
      context,
      CvSection(
        id: id,
        type: _type,
        titleAr: _titleArController.text.trim(),
        titleEn: _titleEnController.text.trim(),
        visible: existing?.visible ?? true,
        order: existing?.order ?? widget.nextOrder,
        data: existing?.data ?? <String, dynamic>{},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.section != null;

    return AlertDialog(
      title: Text(editing ? 'Edit CV Section' : 'Add CV Section'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _idController,
                enabled: !editing,
                decoration: const InputDecoration(
                  labelText: 'Section ID',
                  hintText: 'e.g. achievements',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleArController,
                decoration: const InputDecoration(labelText: 'Arabic title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleEnController,
                decoration: const InputDecoration(labelText: 'English title'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Section type'),
                items: [
                  for (final type in _types)
                    DropdownMenuItem(value: type, child: Text(type)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'The section type controls which editor/rendering behavior we add later. Custom sections remain fully dynamic.',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
