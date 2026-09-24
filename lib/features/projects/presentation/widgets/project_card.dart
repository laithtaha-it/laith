import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/project.dart';

/// A project entry in the `/projects` grid, styled as a small case-study
/// card rather than a generic rounded template card — sharp/minimal radius,
/// no drop shadow, quiet hover state. This keeps the grid visually
/// consistent with the rest of the site (Hero, Featured Projects, Skills).
class ProjectCard extends StatefulWidget {
  const ProjectCard({
    required this.project,
    required this.onTap,
    this.index,
    super.key,
  });

  final Project project;
  final VoidCallback onTap;

  /// Zero-based position in the grid, used to render a "01", "02", ...
  /// case-study number. Optional so this widget still works anywhere a
  /// bare project card is wanted without numbering.
  final int? index;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final project = widget.project;

    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: theme.colorScheme.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: _hovered
                  ? theme.colorScheme.primary.withValues(alpha: 0.45)
                  : theme.colorScheme.outline,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ProjectImage(url: project.imageUrl, hovered: _hovered),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 190),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.index != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: Text(
                              (widget.index! + 1).toString().padLeft(2, '0'),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: AppTypography.meta(context),
                                fontWeight: FontWeight.w600,
                                letterSpacing: .4,
                              ),
                            ),
                          ),
                        Text(
                          project.title(
                            Localizations.localeOf(context).languageCode,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: AppTypography.projectTitle(context) * .74,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          project.shortDescription(
                            Localizations.localeOf(context).languageCode,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: .68,
                            ),
                            fontSize: AppTypography.body(context),
                            height: AppTypography.bodyLineHeight(context),
                          ),
                        ),
                        if (project.technologies.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _TechnologyBadges(
                            technologies: project.technologies,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        _ViewProjectLink(hovered: _hovered, isArabic: isArabic),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectImage extends StatelessWidget {
  const _ProjectImage({required this.url, required this.hovered});

  final String url;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRect(
        child: AnimatedScale(
          scale: hovered ? 1.03 : 1,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: url.trim().isEmpty
              ? const _ImagePlaceholder()
              : _ProjectNetworkOrAssetImage(
                  url: url,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
        ),
      ),
    );
  }
}

class _ProjectNetworkOrAssetImage extends StatelessWidget {
  const _ProjectNetworkOrAssetImage({
    required this.url,
    required this.fit,
    required this.filterQuality,
  });

  final String url;
  final BoxFit fit;
  final FilterQuality filterQuality;

  bool get _isNetwork {
    final uri = Uri.tryParse(url.trim());

    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return Image.network(
        url,
        fit: fit,
        filterQuality: filterQuality,
        errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }

          return const _ImagePlaceholder(showLoading: true);
        },
      );
    }

    return Image.asset(
      url,
      fit: fit,
      filterQuality: filterQuality,
      errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.showLoading = false});

  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: showLoading
            ? SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : Icon(
                Icons.image_outlined,
                size: 38,
                color: theme.colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}

class _TechnologyBadges extends StatelessWidget {
  const _TechnologyBadges({required this.technologies});

  final List<String> technologies;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        for (final technology in technologies.take(6))
          Text(
            technology,
            style: TextStyle(
              fontSize: AppTypography.meta(context) - 1,
              color: theme.colorScheme.onSurface.withValues(alpha: .52),
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

/// Quiet text+arrow link — matches the "Details ->" pattern used in the
/// Home Featured Projects section, instead of a separate colored pill
/// button style.
class _ViewProjectLink extends StatelessWidget {
  const _ViewProjectLink({required this.hovered, required this.isArabic});

  final bool hovered;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = hovered
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: .75);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isArabic ? 'عرض المشروع' : 'View Project',
          style: TextStyle(
            color: color,
            fontSize: AppTypography.button,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        AnimatedSlide(
          duration: const Duration(milliseconds: 180),
          offset: Offset(hovered ? (isArabic ? -0.15 : 0.15) : 0, 0),
          child: Icon(
            isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
            size: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}
