import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../features/admin/presentation/widgets/admin_scaffold.dart';
import '../../domain/entities/cv_color_settings.dart';
import '../bloc/cv_colors_cubit.dart';

class AdminCvColorsPage extends StatefulWidget {
  const AdminCvColorsPage({super.key});

  @override
  State<AdminCvColorsPage> createState() => _AdminCvColorsPageState();
}

class _AdminCvColorsPageState extends State<AdminCvColorsPage> {
  late CvColorSettings _draft;

  @override
  void initState() {
    super.initState();
    _draft = context.read<CvColorsCubit>().state.colors;
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'CV Colors',
      child: BlocConsumer<CvColorsCubit, CvColorsState>(
        listener: (context, state) {
          if (state.status == CvColorsStatus.loaded) {
            setState(() {
              _draft = state.colors;
            });
          }

          if (state.status == CvColorsStatus.failure && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save CV colors: ${state.message}'),
              ),
            );
          }
        },
        builder: (context, state) {
          final saving = state.status == CvColorsStatus.saving;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;
              final horizontalPadding = isSmallScreen
                  ? 12.0
                  : constraints.maxWidth >= 900
                  ? 32.0
                  : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'CV COLORS',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Control only the colors used by the CV. '
                          'The website COLORS are independent.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        _ColorGrid(
                          colors: _draft,
                          onChanged: (updated) {
                            setState(() {
                              _draft = updated;
                            });
                          },
                        ),
                        const SizedBox(height: 28),
                        _ActionButtons(
                          saving: saving,
                          onReset: () {
                            setState(() {
                              _draft = CvColorSettings.defaults;
                            });
                          },
                          onSave: () async {
                            final ok = await context.read<CvColorsCubit>().save(
                              _draft,
                            );

                            if (ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'CV colors saved successfully.',
                                  ),
                                ),
                              );
                            }
                          },
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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.saving,
    required this.onReset,
    required this.onSave,
  });

  final bool saving;
  final VoidCallback onReset;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 420;

        if (isSmall) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: saving ? null : onReset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset'),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: saving ? null : onSave,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(saving ? 'Saving...' : 'Save CV Colors'),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: saving ? null : onReset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(saving ? 'Saving...' : 'Save CV Colors'),
            ),
          ],
        );
      },
    );
  }
}

class _ColorGrid extends StatelessWidget {
  const _ColorGrid({required this.colors, required this.onChanged});

  final CvColorSettings colors;
  final ValueChanged<CvColorSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final fields = <_ColorFieldData>[
      _ColorFieldData(
        'Background',
        colors.background,
        (color) => colors.copyWith(background: color),
      ),
      _ColorFieldData(
        'White / Surface',
        colors.white,
        (color) => colors.copyWith(white: color),
      ),
      _ColorFieldData(
        'Black',
        colors.black,
        (color) => colors.copyWith(black: color),
      ),
      _ColorFieldData(
        'Dark 202020',
        colors.dark2020,
        (color) => colors.copyWith(dark2020: color),
      ),
      _ColorFieldData(
        'Dark 222222',
        colors.dark2222,
        (color) => colors.copyWith(dark2222: color),
      ),
      _ColorFieldData(
        'Dark 242424',
        colors.dark2424,
        (color) => colors.copyWith(dark2424: color),
      ),
      _ColorFieldData(
        'Dark 252525',
        colors.dark2525,
        (color) => colors.copyWith(dark2525: color),
      ),
      _ColorFieldData(
        'Dark 303030',
        colors.dark3030,
        (color) => colors.copyWith(dark3030: color),
      ),
      _ColorFieldData(
        'Dark 333333',
        colors.dark3333,
        (color) => colors.copyWith(dark3333: color),
      ),
      _ColorFieldData(
        'Gray 555555',
        colors.gray5555,
        (color) => colors.copyWith(gray5555: color),
      ),
      _ColorFieldData(
        'Gray 666666',
        colors.gray6666,
        (color) => colors.copyWith(gray6666: color),
      ),
      _ColorFieldData(
        'Gray 777777',
        colors.gray7777,
        (color) => colors.copyWith(gray7777: color),
      ),
      _ColorFieldData(
        'Accent',
        colors.accent,
        (color) => colors.copyWith(accent: color),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        final spacing = 16.0;
        final width =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final field in fields)
              SizedBox(
                width: width,
                child: _ColorTile(
                  field: field,
                  onChanged: (color) {
                    onChanged(field.apply(color));
                  },
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
  final CvColorSettings Function(Color) apply;
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({required this.field, required this.onChanged});

  final _ColorFieldData field;
  final ValueChanged<Color> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await _showColorPicker(context, field.color);

    if (selected != null) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _openPicker(context),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: field.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _hex(field.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Choose color',
              onPressed: () => _openPicker(context),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Color?> _showColorPicker(BuildContext context, Color initial) async {
  Color selected = initial;

  final controller = TextEditingController(text: _hex(initial));

  String? errorText;

  final screenWidth = MediaQuery.sizeOf(context).width;

  final pickerWidth = screenWidth < 600
      ? (screenWidth - 64).clamp(260.0, 340.0)
      : 340.0;

  final result = await showDialog<Color>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          void updateFromPicker(Color color) {
            setDialogState(() {
              selected = color;

              controller.text = _hex(color);

              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );

              errorText = null;
            });
          }

          void applyHex() {
            final parsed = _parseHexColor(controller.text);

            if (parsed == null) {
              setDialogState(() {
                errorText = 'Enter a valid HEX color, e.g. #165D9A';
              });
              return;
            }

            setDialogState(() {
              selected = parsed;
              errorText = null;
            });
          }

          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            title: const Text('Choose color'),
            contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            content: SizedBox(
              width: pickerWidth,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ColorPicker(
                      key: ValueKey(_hex(selected)),
                      pickerColor: selected,
                      onColorChanged: updateFromPicker,

                      // Prevent the internal horizontal layout
                      // from overflowing on small screens.
                      portraitOnly: true,

                      // We already have our own HEX field below.
                      labelTypes: const [],

                      // Keep the picker at a controlled width.
                      colorPickerWidth: pickerWidth,

                      // Slightly shorter picker for a more
                      // comfortable dialog.
                      pickerAreaHeightPercent: 0.75,

                      enableAlpha: false,
                      displayThumbColor: true,

                      paletteType: PaletteType.hsvWithHue,

                      pickerAreaBorderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                      enableSuggestions: false,
                      maxLength: 7,
                      decoration: InputDecoration(
                        labelText: 'HEX',
                        hintText: '#165D9A',
                        prefixIcon: const Icon(Icons.tag),
                        errorText: errorText,
                        counterText: '',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final parsed = _parseHexColor(value);

                        setDialogState(() {
                          if (parsed != null) {
                            selected = parsed;
                            errorText = null;
                          } else if (value.trim().isNotEmpty) {
                            errorText = null;
                          } else {
                            errorText = null;
                          }
                        });
                      },
                      onSubmitted: (_) {
                        applyHex();
                      },
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Enter a 6-digit HEX value with or without #.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final parsed = _parseHexColor(controller.text);

                  if (parsed == null) {
                    setDialogState(() {
                      errorText = 'Enter a valid HEX color, e.g. #165D9A';
                    });
                    return;
                  }

                  Navigator.of(dialogContext).pop(parsed);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );

  controller.dispose();

  return result;
}

Color? _parseHexColor(String value) {
  var hex = value.trim();

  if (hex.startsWith('#')) {
    hex = hex.substring(1);
  }

  if (hex.length == 6) {
    hex = 'FF$hex';
  }

  if (hex.length != 8) {
    return null;
  }

  if (!RegExp(r'^[0-9a-fA-F]{8}$').hasMatch(hex)) {
    return null;
  }

  return Color(int.parse(hex, radix: 16));
}

String _hex(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}
