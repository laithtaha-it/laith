import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/responsive_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/project.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';

class ProjectDetailsPage extends StatefulWidget {
  const ProjectDetailsPage({required this.projectId, super.key});

  final String projectId;

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProjectBloc>().add(LoadProjectById(widget.projectId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _ProjectDetailsView();
  }
}

class _ProjectDetailsView extends StatelessWidget {
  const _ProjectDetailsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ResponsiveContainer(
        maxWidth: 1200,
        child: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            if (state is ProjectInitial || state is ProjectLoading) {
              return const _DetailsShimmer();
            }

            if (state is ProjectNotFound) {
              return _StateMessage(
                icon: Icons.search_off_outlined,
                title: l10n.projectNotFound,
                actionLabel: l10n.backToProjects,
                onAction: () => context.go('/projects'),
              );
            }

            if (state is ProjectError) {
              return _StateMessage(
                icon: Icons.error_outline_rounded,
                title: _errorText(context, state.message),
                actionLabel: l10n.backToProjects,
                onAction: () => context.go('/projects'),
              );
            }

            if (state is ProjectDetailsLoaded) {
              return _Details(project: state.project);
            }

            return const _DetailsShimmer();
          },
        ),
      ),
    );
  }

  String _errorText(BuildContext context, String message) {
    if (message.trim().isNotEmpty) return message;

    return Localizations.localeOf(context).languageCode == 'ar'
        ? 'تعذر تحميل المشروع حاليًا.'
        : 'Unable to load this project right now.';
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final isArabic = languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/projects');
              }
            },
            icon: Icon(
              isArabic ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            ),
            label: Text(l10n.backToProjects),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            project.title(languageCode),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: AppTypography.sectionHeading(context),
              height: AppTypography.headingLineHeight(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              project.shortDescription(languageCode),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: .70),
                fontSize: AppTypography.subheading(context),
                height: AppTypography.bodyLineHeight(context),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _HeroImage(url: project.imageUrl),
          if (project.description(languageCode).trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxxl),
            _DetailHeading(
              label: isArabic ? 'نظرة عامة' : 'Overview',
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Text(
                project.description(languageCode),
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: AppTypography.bodyLineHeight(context),
                  fontSize: AppTypography.body(context),
                  color: theme.colorScheme.onSurface.withValues(alpha: .75),
                ),
              ),
            ),
          ],
          if (project.technologies.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxxl),
            _DetailHeading(label: l10n.projectTechnologies),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final technology in project.technologies)
                  _TechnologyChip(technology: technology),
              ],
            ),
          ],
          if (project.galleryImages.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxxl),
            _DetailHeading(label: l10n.projectGallery),
            const SizedBox(height: AppSpacing.md),
            _Gallery(images: project.galleryImages),
          ],
          if (project.githubUrl != null || project.liveUrl != null) ...[
            const SizedBox(height: AppSpacing.xxxl),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                if (project.githubUrl != null)
                  OutlinedButton.icon(
                    onPressed: () => _openUrl(context, project.githubUrl!),
                    icon: const Icon(Icons.code_rounded, size: 18),
                    label: Text(l10n.projectGithub),
                  ),
                if (project.liveUrl != null)
                  FilledButton.icon(
                    onPressed: () => _openUrl(context, project.liveUrl!),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(l10n.projectLive),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String value) async {
    final uri = Uri.tryParse(value.trim());

    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'تعذر فتح الرابط.'
                : 'Unable to open the link.',
          ),
        ),
      );
    }
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // A restrained border instead of a heavy drop shadow — matches the
    // sharp/technical image treatment used on Home (Featured Projects,
    // ImageWidget) rather than a generic "rounded card with glow" look.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: url.trim().isEmpty
              ? const _ImagePlaceholder()
              : _ProjectNetworkOrAssetImage(
                  url: url,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 600 ? 3 : 6;

        const gap = 14.0;

        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final image in images)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: width,
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: image.trim().isEmpty
                        ? const _ImagePlaceholder()
                        : _ProjectNetworkOrAssetImage(
                            url: image,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                  ),
                ),
              ),
          ],
        );
      },
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

/// A quiet, small eyebrow-style heading used above Overview / Technologies
/// / Gallery blocks — matches the accent-colored label pattern used
/// elsewhere on the site instead of a heavy w800 titleLarge.
class _DetailHeading extends StatelessWidget {
  const _DetailHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      label,
      style: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: AppTypography.meta(context),
        fontWeight: FontWeight.w600,
        letterSpacing: .6,
      ),
    );
  }
}

class _TechnologyChip extends StatelessWidget {
  const _TechnologyChip({required this.technology});

  final String technology;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        technology,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: .78),
          fontSize: AppTypography.meta(context),
          fontWeight: FontWeight.w500,
        ),
      ),
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
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : Icon(
                Icons.image_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}

class _DetailsShimmer extends StatelessWidget {
  const _DetailsShimmer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(
            width: 150,
            height: 40,
            color: theme.dividerColor.withValues(alpha: 0.5),
            radius: 4,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _SkeletonBox(
            width: 360,
            height: 40,
            color: theme.dividerColor.withValues(alpha: 0.5),
            radius: 4,
          ),
          const SizedBox(height: AppSpacing.md),
          _SkeletonBox(
            width: 560,
            height: 20,
            color: theme.dividerColor.withValues(alpha: 0.5),
            radius: 4,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _SkeletonBox(
              color: theme.dividerColor.withValues(alpha: 0.5),
              radius: 4,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          _SkeletonBox(
            width: double.infinity,
            height: 120,
            color: theme.dividerColor.withValues(alpha: 0.5),
            radius: 4,
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.color,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  final Color color;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: theme.colorScheme.primary),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
