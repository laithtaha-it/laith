import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../domain/entities/app_color_settings.dart';
import '../bloc/colors_cubit.dart';
import '../../../../features/admin/presentation/widgets/admin_scaffold.dart';

class AdminColorsPage extends StatefulWidget {
  const AdminColorsPage({super.key});

  @override
  State<AdminColorsPage> createState() => _AdminColorsPageState();
}

class _AdminColorsPageState extends State<AdminColorsPage> {
  late AppColorSettings _draft;

  @override
  void initState() {
    super.initState();
    _draft = context.read<ColorsCubit>().state.colors;
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Colors',
      child: BlocConsumer<ColorsCubit, ColorsState>(
        listener: (context, state) {
          if (state.status == ColorsStatus.loaded) {
            _draft = state.colors;
          }

          if (state.status == ColorsStatus.failure && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save colors: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final saving = state.status == ColorsStatus.saving;

          return LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'COLORS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Control the main website theme colors. The CV keeps its own design and is not affected.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        _ColorGrid(
                          colors: _draft,
                          onChanged: (updated) => setState(() => _draft = updated),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () => setState(() {
                                        _draft = AppColorSettings.defaults;
                                      }),
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('Reset'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: saving
                                  ? null
                                  : () async {
                                      final ok = await context
                                          .read<ColorsCubit>()
                                          .save(_draft);
                                      if (ok && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Colors saved successfully.'),
                                          ),
                                        );
                                      }
                                    },
                              icon: saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(saving ? 'Saving...' : 'Save Colors'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  const _ColorGrid({required this.colors, required this.onChanged});

  final AppColorSettings colors;
  final ValueChanged<AppColorSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final fields = <_ColorFieldData>[
      _ColorFieldData('Scaffold Background', colors.scaffoldBackground, (c) => colors.copyWith(scaffoldBackground: c)),
      _ColorFieldData('Surface', colors.surface, (c) => colors.copyWith(surface: c)),
      _ColorFieldData('Primary Text', colors.primaryText, (c) => colors.copyWith(primaryText: c)),
      _ColorFieldData('Secondary Text', colors.secondaryText, (c) => colors.copyWith(secondaryText: c)),
      _ColorFieldData('Accent', colors.accent, (c) => colors.copyWith(accent: c)),
      _ColorFieldData('Border', colors.border, (c) => colors.copyWith(border: c)),
      _ColorFieldData('Error', colors.error, (c) => colors.copyWith(error: c)),
      _ColorFieldData('Success', colors.success, (c) => colors.copyWith(success: c)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        final width = (constraints.maxWidth - (columns - 1) * 16) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final field in fields)
              SizedBox(
                width: width,
                child: _ColorTile(
                  field: field,
                  onChanged: (color) => onChanged(field.apply(color)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ColorFieldData {
  const _ColorFieldData(this.label, this.color, this.apply);

  final String label;
  final Color color;
  final AppColorSettings Function(Color color) apply;
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({required this.field, required this.onChanged});

  final _ColorFieldData field;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final selected = await _showColorPicker(context, field.color);
                if (selected != null) onChanged(selected);
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: field.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(field.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(_hex(field.color)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Choose color',
              onPressed: () async {
                final selected = await _showColorPicker(context, field.color);
                if (selected != null) onChanged(selected);
              },
              icon: const Icon(Icons.colorize),
            ),
          ],
        ),
      ),
    );
  }

  Future<Color?> _showColorPicker(BuildContext context, Color initial) {
    var selected = initial;

    return showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose ${field.label}'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initial,
              onColorChanged: (color) => selected = color,
              enableAlpha: false,
              hexInputBar: true,
              labelTypes: const [ColorLabelType.hex],
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(selected),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  static String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}
