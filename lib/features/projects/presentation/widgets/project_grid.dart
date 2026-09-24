import 'package:flutter/material.dart';

import '../../domain/entities/project.dart';
import 'project_card.dart';

class ProjectGrid extends StatelessWidget {
  const ProjectGrid({
    required this.projects,
    required this.onProjectTap,
    super.key,
  });

  final List<Project> projects;
  final ValueChanged<Project> onProjectTap;

  @override
  Widget build(BuildContext context) {
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

        if (columns == 1) {
          return Column(
            children: [
              for (var i = 0; i < projects.length; i++) ...[
                SizedBox(
                  width: itemWidth,
                  child: ProjectCard(
                    project: projects[i],
                    index: i,
                    onTap: () => onProjectTap(projects[i]),
                  ),
                ),
                if (i < projects.length - 1) SizedBox(height: gap),
              ],
            ],
          );
        }

        final rows = <List<Project>>[];

        for (var i = 0; i < projects.length; i += columns) {
          final end = (i + columns).clamp(0, projects.length);
          rows.add(projects.sublist(i, end));
        }

        return Column(
          children: [
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      var columnIndex = 0;
                      columnIndex < rows[rowIndex].length;
                      columnIndex++
                    ) ...[
                      SizedBox(
                        width: itemWidth,
                        child: ProjectCard(
                          project: rows[rowIndex][columnIndex],
                          index: rowIndex * columns + columnIndex,
                          onTap: () =>
                              onProjectTap(rows[rowIndex][columnIndex]),
                        ),
                      ),
                      if (columnIndex < rows[rowIndex].length - 1)
                        SizedBox(width: gap),
                    ],
                  ],
                ),
              ),
              if (rowIndex < rows.length - 1) SizedBox(height: gap),
            ],
          ],
        );
      },
    );
  }
}
