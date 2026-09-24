import 'package:flutter/material.dart';

class ProjectShimmer extends StatelessWidget {
  const ProjectShimmer({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.dividerColor.withValues(alpha: 0.45);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width < 640
            ? 1
            : width < 1024
            ? 2
            : 3;
        final gap = width < 640 ? 16.0 : 22.0;
        final itemWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(
            itemCount,
            (_) => SizedBox(
              width: itemWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ColoredBox(color: base),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Box(width: 28, height: 14, color: base),
                          const SizedBox(height: 12),
                          _Box(width: itemWidth * .55, height: 22, color: base),
                          const SizedBox(height: 10),
                          _Box(width: double.infinity, height: 13, color: base),
                          const SizedBox(height: 8),
                          _Box(width: itemWidth * .82, height: 13, color: base),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 7,
                            children: [
                              _Box(width: 48, height: 12, color: base),
                              _Box(width: 58, height: 12, color: base),
                              _Box(width: 40, height: 12, color: base),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _Box(width: 96, height: 16, color: base),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
