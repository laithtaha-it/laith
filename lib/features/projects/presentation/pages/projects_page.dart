import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/responsive_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import '../widgets/project_grid.dart';
import '../widgets/project_shimmer.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProjectBloc>().add(const LoadProjects());
      }
    });
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      body: ResponsiveContainer(
        maxWidth: 1200,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                bottom: AppSpacing.xl,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => _goBack(context),
                        icon: Icon(
                          isArabic
                              ? Icons.arrow_forward_rounded
                              : Icons.arrow_back_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isArabic ? 'العودة للرئيسية' : 'Back to Home',
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    Text(
                      isArabic ? 'أعمالي' : 'Portfolio',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: AppTypography.meta(context),
                        fontWeight: FontWeight.w600,
                        letterSpacing: .3,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.labelToHeading),

                    Text(
                      l10n.projects,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: AppTypography.sectionHeading(context),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Text(
                        isArabic
                            ? 'مجموعة من التطبيقات والمنتجات التي عملت على بنائها، مع التركيز على الجودة والأداء وتجربة المستخدم.'
                            : 'A collection of applications and products I have built, with a focus on quality, performance, and user experience.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: .70,
                          ),
                          fontSize: AppTypography.body(context),
                          height: AppTypography.bodyLineHeight(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              sliver: SliverToBoxAdapter(
                child: BlocBuilder<ProjectBloc, ProjectState>(
                  builder: (context, state) {
                    return _Content(state: state);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final ProjectState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state is ProjectInitial || state is ProjectLoading) {
      return const ProjectShimmer();
    }

    if (state is ProjectError) {
      return _Message(
        icon: Icons.error_outline_rounded,
        text: _friendlyError(context, (state as ProjectError).message),
        action: () {
          context.read<ProjectBloc>().add(const LoadProjects());
        },
        actionLabel: l10n.retry,
      );
    }

    if (state is ProjectsLoaded) {
      final projects = (state as ProjectsLoaded).projects;

      if (projects.isEmpty) {
        return _Message(
          icon: Icons.work_outline_rounded,
          text: l10n.noProjects,
        );
      }

      return ProjectGrid(
        projects: projects,
        onProjectTap: (project) {
          context.push('/projects/${project.id}');
        },
      );
    }

    return const ProjectShimmer();
  }

  String _friendlyError(BuildContext context, String message) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (message.trim().isEmpty) {
      return isArabic
          ? 'تعذر تحميل المشاريع حاليًا.'
          : 'Unable to load projects right now.';
    }

    return message;
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.action,
    this.actionLabel,
  });

  final IconData icon;
  final String text;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: theme.colorScheme.primary),
          const SizedBox(height: 18),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          if (action != null) ...[
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: action,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                actionLabel ?? MaterialLocalizations.of(context).okButtonLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
