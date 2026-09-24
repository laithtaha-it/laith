import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/responsive_container.dart';
import '../../../../core/widgets/scroll_reveal.dart';
import '../../domain/entities/home_content.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_navbar.dart';
import '../../../contact/presentation/bloc/contact_bloc.dart';
import '../../../contact/presentation/bloc/contact_event.dart';
import '../../../contact/presentation/bloc/contact_state.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/bloc/project_bloc.dart';
import '../../../projects/presentation/bloc/project_event.dart';
import '../../../projects/presentation/bloc/project_state.dart';
import '../../../skills/domain/entities/skill.dart';
import '../../../skills/presentation/bloc/skill_bloc.dart';
import '../../../skills/presentation/bloc/skill_event.dart';
import '../../../skills/presentation/bloc/skill_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();

  final _keys = <String, GlobalKey>{
    'about': GlobalKey(),
    'projects': GlobalKey(),
    'skills': GlobalKey(),
    'contact': GlobalKey(),
  };

  bool _programmatic = false;
  String? _pendingFragment;
  bool _fragmentNavigationScheduled = false;

  final Map<String, double> _sectionOffsets = {};
  bool _measureScheduled = false;

  // --------------------------------------------------------------------------
  // Sequential background loading guards
  // --------------------------------------------------------------------------

  bool _featuredProjectsLoadStarted = false;
  bool _skillsLoadStarted = false;
  bool _contactLoadStarted = false;
  bool _projectsPrefetchStarted = false;

  String _lastFragment = '';

  @override
  void initState() {
    super.initState();

    _scroll.addListener(_onScroll);

    // ------------------------------------------------------------------------
    // IMPORTANT:
    // HomeNavbar does not own the ScrollController.
    // HomePage does, so the navbar sends section navigation requests here.
    // ------------------------------------------------------------------------
    HomeNavbar.onSectionNavigate = _handleNavbarSectionNavigation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _scheduleMeasure();
      _prepareFragmentNavigation();

      // Home may already be loaded before this page finishes mounting.
      // Start the sequential loading pipeline only after Home is ready.
      _startSequenceIfHomeReady();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final fragment = GoRouterState.of(context).uri.fragment;

    if (fragment == _lastFragment) {
      return;
    }

    _lastFragment = fragment;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _handleRouteFragment(fragment);
    });
  }

  @override
  void dispose() {
    // Remove the global navbar callback when this HomePage is destroyed.
    HomeNavbar.onSectionNavigate = null;

    _scroll.removeListener(_onScroll);
    _scroll.dispose();

    super.dispose();
  }

  // ============================================================
  // ACTIVE SECTION
  // ============================================================

  void _setActive(String section) {
    HomeNavbar.setActiveSection(section);
  }

  // ============================================================
  // NAVBAR SECTION NAVIGATION
  // ============================================================

  void _handleNavbarSectionNavigation(String section) {
    if (!mounted) return;

    // Keep the fragment in sync with the direct navbar navigation.
    //
    // This prevents didChangeDependencies() from immediately performing
    // the exact same scroll again after GoRouter changes the URL.
    _lastFragment = section;

    _scrollTo(section);
  }

  // ============================================================
  // SCROLL TRACKING
  // ============================================================

  void _onScroll() {
    if (!_scroll.hasClients) return;

    if (_programmatic) return;

    final offset = _scroll.offset;
    final max = _scroll.position.maxScrollExtent;

    if (offset >= max - 80) {
      _setActive('contact');
      return;
    }

    if (_sectionOffsets.isEmpty) {
      _scheduleMeasure();
      return;
    }

    var active = 'home';

    final sorted = _sectionOffsets.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (final entry in sorted) {
      if (entry.value <= offset + 150) {
        active = entry.key;
      }
    }

    _setActive(active);
  }

  // ============================================================
  // SEQUENTIAL BACKGROUND LOADS
  // ============================================================

  /// Starts the first stage only after Home itself is loaded.
  ///
  /// The remaining stages are triggered from BlocListeners:
  ///
  /// Home
  ///   -> Featured Projects
  ///   -> Skills
  ///   -> Contact
  ///   -> Full Projects Prefetch
  ///
  /// This intentionally avoids starting all Firestore requests at once.
  void _startSequenceIfHomeReady() {
    if (!mounted || _featuredProjectsLoadStarted) return;

    final state = context.read<HomeBloc>().state;

    if (state is! HomeLoaded) {
      return;
    }

    _startFeaturedProjectsLoad();
  }

  void _startFeaturedProjectsLoad() {
    if (!mounted || _featuredProjectsLoadStarted) return;

    _featuredProjectsLoadStarted = true;

    context.read<ProjectBloc>().add(const LoadFeaturedProjects());
  }

  void _startSkillsLoad() {
    if (!mounted || _skillsLoadStarted) return;

    _skillsLoadStarted = true;

    context.read<SkillBloc>().add(const LoadSkills());
  }

  void _startContactLoad() {
    if (!mounted || _contactLoadStarted) return;

    _contactLoadStarted = true;

    context.read<ContactBloc>().add(const LoadContactContent());
  }

  void _startProjectsPrefetch() {
    if (!mounted || _projectsPrefetchStarted) return;

    _projectsPrefetchStarted = true;

    // IMPORTANT:
    // PrefetchProjects does not emit ProjectLoading/ProjectsLoaded.
    // It only fills the shared ProjectRepository cache.
    //
    // This means the currently visible FeaturedProjectsLoaded state
    // remains untouched while the complete projects list is prefetched.
    context.read<ProjectBloc>().add(const PrefetchProjects());
  }

  // ============================================================
  // PROJECT STATE SEQUENCE
  // ============================================================

  void _onProjectStateChanged(BuildContext context, ProjectState state) {
    // The first stage is finished when featured projects either loaded
    // successfully or failed.
    //
    // Even if Featured Projects fail, we continue to Skills so one
    // failed section does not block the rest of the page.
    if (state is FeaturedProjectsLoaded || state is ProjectError) {
      _startSkillsLoad();
    }
  }

  // ============================================================
  // SKILL STATE SEQUENCE
  // ============================================================

  void _onSkillStateChanged(BuildContext context, SkillState state) {
    // Continue to Contact after Skills succeeds or fails.
    if (state is SkillsLoaded || state is SkillError) {
      _startContactLoad();
    }
  }

  // ============================================================
  // CONTACT STATE SEQUENCE
  // ============================================================

  void _onContactStateChanged(BuildContext context, ContactState state) {
    // Contact has completed regardless of whether data exists or an error
    // occurred, so now we can silently prefetch the complete Projects data.
    if (state is ContactLoaded ||
        state is ContactEmpty ||
        state is ContactError) {
      _startProjectsPrefetch();
    }
  }

  // ============================================================
  // SECTION MEASUREMENT
  // ============================================================

  void _scheduleMeasure() {
    if (_measureScheduled || !mounted) return;

    _measureScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;

      if (!mounted || !_scroll.hasClients) return;

      final viewport = _scroll.position.context.notificationContext
          ?.findRenderObject();

      if (viewport is! RenderBox || !viewport.hasSize) return;

      final top = viewport.localToGlobal(Offset.zero).dy;
      final current = _scroll.offset;

      final measured = <String, double>{};

      for (final entry in _keys.entries) {
        final target = entry.value.currentContext?.findRenderObject();

        if (target is! RenderBox || !target.hasSize) continue;

        measured[entry.key] =
            (current + target.localToGlobal(Offset.zero).dy - top)
                .clamp(0, double.infinity)
                .toDouble();
      }

      if (measured.isNotEmpty) {
        _sectionOffsets
          ..clear()
          ..addAll(measured);

        _onScroll();
      }
    });
  }

  // ============================================================
  // ROUTE / FRAGMENT
  // ============================================================

  void _prepareFragmentNavigation() {
    final fragment = GoRouterState.of(context).uri.fragment;

    _lastFragment = fragment;

    _handleRouteFragment(fragment);
  }

  void _handleRouteFragment(String fragment) {
    if (fragment.isEmpty) {
      _pendingFragment = null;

      if (_scroll.hasClients) {
        _programmatic = true;

        _scroll
            .animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: const Cubic(0.645, 0.045, 0.355, 1.0),
            )
            .whenComplete(() {
              if (mounted) {
                _programmatic = false;
              }
            });
      }

      _setActive('home');
      return;
    }

    if (!_keys.containsKey(fragment)) {
      _pendingFragment = null;
      return;
    }

    _pendingFragment = fragment;

    _setActive(fragment);

    _tryPendingFragmentNavigation();
  }

  void _tryPendingFragmentNavigation() {
    final section = _pendingFragment;

    if (section == null || !mounted || _fragmentNavigationScheduled) {
      return;
    }

    final targetContext = _keys[section]?.currentContext;

    if (targetContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _fragmentNavigationScheduled = false;

        _tryPendingFragmentNavigation();
      });

      return;
    }

    _fragmentNavigationScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fragmentNavigationScheduled = false;

      if (!mounted || _pendingFragment != section) return;

      final currentTarget = _keys[section]?.currentContext;

      if (currentTarget == null) {
        _tryPendingFragmentNavigation();
        return;
      }

      _pendingFragment = null;

      await _scrollTo(section, animate: true);
    });
  }

  // ============================================================
  // ACTUAL SECTION SCROLL
  // ============================================================

  Future<void> _scrollTo(String section, {bool animate = true}) async {
    if (!_keys.containsKey(section)) return;

    final targetContext = _keys[section]?.currentContext;

    if (targetContext == null) {
      _pendingFragment = section;

      _setActive(section);

      return;
    }

    _programmatic = true;

    _setActive(section);

    await Scrollable.ensureVisible(
      targetContext,
      duration: animate ? const Duration(milliseconds: 650) : Duration.zero,
      curve: const Cubic(0.645, 0.045, 0.355, 1.0),
      alignment: 0.04,
    );

    if (!mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 80));

    if (mounted) {
      _programmatic = false;
    }
  }

  void scrollToSection(String section) {
    _scrollTo(section);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (previous, current) {
            return current is HomeLoaded;
          },
          listener: (context, state) {
            _startFeaturedProjectsLoad();
          },
        ),
        BlocListener<ProjectBloc, ProjectState>(
          listenWhen: (previous, current) {
            return current is FeaturedProjectsLoaded || current is ProjectError;
          },
          listener: _onProjectStateChanged,
        ),
        BlocListener<SkillBloc, SkillState>(
          listenWhen: (previous, current) {
            return current is SkillsLoaded || current is SkillError;
          },
          listener: _onSkillStateChanged,
        ),
        BlocListener<ContactBloc, ContactState>(
          listenWhen: (previous, current) {
            return current is ContactLoaded ||
                current is ContactEmpty ||
                current is ContactError;
          },
          listener: _onContactStateChanged,
        ),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              _startSequenceIfHomeReady();
              _tryPendingFragmentNavigation();
              _scheduleMeasure();
            });

            return _LoadedHome(
              content: state.content,
              keys: _keys,
              scrollTo: scrollToSection,
              scroll: _scroll,
            );
          }

          if (state is HomeError) {
            return _HomeMessage(
              message: state.message,
              retry: () {
                context.read<HomeBloc>().add(const LoadHomeContent());
              },
            );
          }

          return const _HomeLoading();
        },
      ),
    );
  }
}

class _LoadedHome extends StatelessWidget {
  const _LoadedHome({
    required this.content,
    required this.keys,
    required this.scrollTo,
    required this.scroll,
  });

  final HomeContent content;
  final Map<String, GlobalKey> keys;
  final void Function(String) scrollTo;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= AppBreakpoints.tablet;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: scroll,
          child: Column(
            children: [
              _Hero(content: content, scrollTo: scrollTo),
              ResponsiveContainer(
                child: Column(
                  children: [
                    _SectionAnchor(
                      key: keys['about']!,
                      child: ScrollRevealWrapper(
                        child: _About(content: content, scrollTo: scrollTo),
                      ),
                    ),
                    _SectionAnchor(
                      key: keys['projects']!,
                      child: ScrollRevealWrapper(
                        child: _Projects(content: content, scroll: scroll),
                      ),
                    ),
                    _SectionAnchor(
                      key: keys['skills']!,
                      child: ScrollRevealWrapper(
                        child: _Skills(content: content),
                      ),
                    ),
                    _SectionAnchor(
                      key: keys['contact']!,
                      child: const ScrollRevealWrapper(child: _Contact()),
                    ),
                    const SizedBox(height: 60),
                    const ScrollRevealWrapper(child: _Footer()),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (desktop) const _SideRail(),
      ],
    );
  }
}

class _SectionAnchor extends StatelessWidget {
  const _SectionAnchor({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class _Hero extends StatelessWidget {
  const _Hero({required this.content, required this.scrollTo});

  final HomeContent content;
  final void Function(String) scrollTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    final width = MediaQuery.sizeOf(context).width;

    // Typography reset: the Hero heading previously scaled up to 76px,
    // which reads as "shouting" rather than premium/editorial. See
    // AppTypography for the full rationale — the WOW here comes from
    // composition and whitespace, not from oversized type.
    final titleSize = AppTypography.hero(context);

    return ResponsiveContainer(
      maxWidth: 1180,
      child: SizedBox(
        height: width < 600 ? 650 : 760,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Reveal(
                delay: 80,
                child: Text(
                  content.role(languageCode),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: AppTypography.meta(context),
                    fontWeight: FontWeight.w600,
                    letterSpacing: .3,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _Reveal(
                delay: 180,
                child: Text(
                  content.headline(languageCode),
                  textAlign: TextAlign.start,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: titleSize,
                    height: AppTypography.headingLineHeight(context),
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: _Reveal(
                  delay: 380,
                  child: Text(
                    content.description(languageCode),
                    textAlign: TextAlign.start,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: .70),
                      fontSize: AppTypography.body(context),
                      height: AppTypography.bodyLineHeight(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              _Reveal(
                delay: 480,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 14,
                  runSpacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: () => scrollTo('projects'),
                      child: Text(content.projectsButton(languageCode)),
                    ),
                    TextButton(
                      onPressed: () => scrollTo('contact'),
                      child: Text(content.contactButton(languageCode)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _About extends StatelessWidget {
  const _About({required this.content, required this.scrollTo});

  final HomeContent content;
  final void Function(String) scrollTo;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    final l10n = AppLocalizations.of(context)!;

    final cvUrl = content.about.cvUrl(languageCode).trim();

    final theme = Theme.of(context);

    return _Section(
      number: '',
      title: content.about.title(languageCode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A constrained measure keeps long-form body copy readable
          // instead of stretching edge-to-edge on wide desktop screens.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              content.about.description(languageCode),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: .75),
                fontSize: AppTypography.body(context),
                height: AppTypography.bodyLineHeight(context),
              ),
            ),
          ),
          if (cvUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: TextButton.icon(
                onPressed: () => context.go('/cv'),
                icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                label: Text(l10n.viewCv),
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: AppTypography.button,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Projects extends StatelessWidget {
  const _Projects({required this.content, required this.scroll});

  final HomeContent content;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    final isArabic = languageCode == 'ar';

    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        return _Section(
          number: '',
          title: content.projects.title(languageCode),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (content.projects.description(languageCode).trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      content.projects.description(languageCode),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: .70),
                        fontSize: AppTypography.body(context),
                        height: AppTypography.bodyLineHeight(context),
                      ),
                    ),
                  ),
                ),
              if (state is FeaturedProjectsLoaded) ...[
                StaggeredScrollList(
                  children: [
                    for (var i = 0; i < state.projects.length; i++)
                      _FeaturedProject(
                        project: state.projects[i],
                        index: i,
                        eyebrow: content.projects.eyebrow(languageCode),
                        scrollController: scroll,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/projects'),
                    icon: Icon(
                      isArabic
                          ? Icons.arrow_back_rounded
                          : Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isArabic
                          ? 'استكشف المزيد من المشاريع'
                          : 'Explore More Projects',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(220, 48),
                      textStyle: const TextStyle(
                        fontSize: AppTypography.button,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else if (state is ProjectError)
                _InlineMessage(text: state.message)
              else
                const _ProjectLoadingRows(),
            ],
          ),
        );
      },
    );
  }
}

class _FeaturedProject extends StatefulWidget {
  const _FeaturedProject({
    required this.project,
    required this.index,
    required this.eyebrow,
    required this.scrollController,
  });

  final Project project;
  final int index;
  final String eyebrow;
  final ScrollController scrollController;

  @override
  State<_FeaturedProject> createState() => _FeaturedProjectState();
}

class _FeaturedProjectState extends State<_FeaturedProject> {
  bool hover = false;

  void _navigateToDetails() {
    context.push('/projects/${widget.project.id}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final languageCode = Localizations.localeOf(context).languageCode;

    final project = widget.project;

    final reverse = widget.index.isOdd;

    final copy = Column(
      crossAxisAlignment: reverse
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (widget.eyebrow.trim().isNotEmpty)
          Text(
            widget.eyebrow,
            textAlign: reverse ? TextAlign.end : TextAlign.start,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: AppTypography.meta(context),
              fontWeight: FontWeight.w600,
              letterSpacing: .4,
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: _navigateToDetails,
          borderRadius: BorderRadius.circular(4),
          child: Text(
            project.title(languageCode),
            textAlign: reverse ? TextAlign.end : TextAlign.start,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: AppTypography.projectTitle(context),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${project.shortDescription(languageCode)} ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: .72),
                    fontSize: AppTypography.body(context),
                    height: AppTypography.bodyLineHeight(context),
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4),
                    child: InkWell(
                      onTap: _navigateToDetails,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              languageCode == 'ar' ? 'التفاصيل' : 'Details',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: AppTypography.meta(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              languageCode == 'ar'
                                  ? Icons.arrow_back_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: reverse ? TextAlign.end : TextAlign.start,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: reverse ? WrapAlignment.end : WrapAlignment.start,
          spacing: 14,
          runSpacing: 8,
          children: [
            for (final technology in project.technologies.take(7))
              Text(
                technology,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: .55),
                  fontSize: AppTypography.meta(context),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: reverse
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (project.githubUrl?.trim().isNotEmpty ?? false)
              IconButton(
                tooltip: 'GitHub',
                onPressed: () => _open(project.githubUrl!),
                icon: SvgPicture.asset(
                  'assets/icons/github.svg',
                  width: 17,
                  height: 17,
                ),
              ),
            if (project.liveUrl?.trim().isNotEmpty ?? false)
              IconButton(
                tooltip: AppLocalizations.of(context)!.projectLive,
                onPressed: () => _open(project.liveUrl!),
                icon: const Icon(Icons.arrow_outward_rounded, size: 18),
              ),
          ],
        ),
      ],
    );

    final image = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: _navigateToDetails,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AnimatedScale(
            scale: hover ? 1.025 : 1,
            duration: const Duration(milliseconds: 260),
            child: project.imageUrl.trim().isEmpty
                ? const SizedBox(height: 280)
                : ImageWidget(
                    url: project.imageUrl,
                    scrollController: widget.scrollController,
                  ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 110),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 820;

          if (stacked) {
            return Column(children: [image, const SizedBox(height: 28), copy]);
          }

          return Row(
            textDirection: reverse ? TextDirection.rtl : TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 6, child: image),
              const SizedBox(width: 30),
              Expanded(flex: 5, child: copy),
            ],
          );
        },
      ),
    );
  }
}

class ImageWidget extends StatefulWidget {
  const ImageWidget({required this.url, this.scrollController, super.key});

  final String url;
  final ScrollController? scrollController;

  bool get network {
    final uri = Uri.tryParse(url);

    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool _activated = false;

  bool get _isNetwork => widget.network;

  @override
  void initState() {
    super.initState();

    if (!_isNetwork || widget.scrollController == null) {
      _activated = true;
      return;
    }

    widget.scrollController!.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _checkVisibility();
    });
  }

  @override
  void didUpdateWidget(covariant ImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);

      if (!_activated && _isNetwork && widget.scrollController != null) {
        widget.scrollController!.addListener(_onScroll);
      }
    }

    if (oldWidget.url != widget.url) {
      if (!_isNetwork || widget.scrollController == null) {
        _activated = true;
      } else {
        _activated = false;

        widget.scrollController?.removeListener(_onScroll);

        widget.scrollController!.addListener(_onScroll);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          _checkVisibility();
        });
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);

    super.dispose();
  }

  void _onScroll() {
    if (_activated) return;

    _checkVisibility();
  }

  void _checkVisibility() {
    if (_activated || !_isNetwork) return;

    final controller = widget.scrollController;

    if (controller == null || !controller.hasClients) {
      return;
    }

    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final viewport = controller.position.context.notificationContext
        ?.findRenderObject();

    if (viewport is! RenderBox || !viewport.hasSize) {
      return;
    }

    final imageTop = renderObject.localToGlobal(Offset.zero).dy;

    final imageBottom = imageTop + renderObject.size.height;

    final viewportTop = viewport.localToGlobal(Offset.zero).dy;

    final viewportBottom = viewportTop + viewport.size.height;

    const preloadDistance = 700.0;

    final nearViewport =
        imageBottom >= viewportTop - preloadDistance &&
        imageTop <= viewportBottom + preloadDistance;

    if (nearViewport) {
      _activate();
    }
  }

  void _activate() {
    if (_activated || !mounted) return;

    _activated = true;

    widget.scrollController?.removeListener(_onScroll);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: !_isNetwork || _activated
            ? (_isNetwork
                  ? Image.network(
                      widget.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const _ImageFallback(),
                    )
                  : Image.asset(
                      widget.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const _ImageFallback(),
                    ))
            : const _ImageFallback(),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 34,
        ),
      ),
    );
  }
}

class _Skills extends StatelessWidget {
  const _Skills({required this.content});

  final HomeContent content;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return BlocBuilder<SkillBloc, SkillState>(
      builder: (context, state) {
        return _Section(
          number: '',
          title: content.skills.title(languageCode),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (content.skills.description(languageCode).trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      content.skills.description(languageCode),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: .70),
                        fontSize: AppTypography.body(context),
                        height: AppTypography.bodyLineHeight(context),
                      ),
                    ),
                  ),
                ),
              if (state is SkillsLoaded)
                _SkillGroups(skills: state.skills, languageCode: languageCode)
              else if (state is SkillError)
                _InlineMessage(text: state.message)
              else
                const _SkillLoading(),
            ],
          ),
        );
      },
    );
  }
}

class _SkillGroups extends StatelessWidget {
  const _SkillGroups({required this.skills, required this.languageCode});

  final List<Skill> skills;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Skill>>{};

    for (final skill in skills) {
      groups
          .putIfAbsent(skill.category(languageCode), () => <Skill>[])
          .add(skill);
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groups.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: ScrollRevealWrapper(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quiet visual anchor per category, in place of a boxed
                  // card — a small accent-colored rule rather than a
                  // container, so the list stays editorial, not templated.
                  Container(
                    width: 2,
                    height: 18,
                    margin: const EdgeInsetsDirectional.only(
                      top: 4,
                      end: AppSpacing.sm,
                    ),
                    color: theme.colorScheme.primary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontSize: AppTypography.subheading(context),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final skill in entry.value)
                              _SkillChip(label: skill.name(languageCode)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: .78),
          fontSize: AppTypography.meta(context),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* CONTACT                                                                    */
/* -------------------------------------------------------------------------- */

class _Contact extends StatelessWidget {
  const _Contact();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        if (state is ContactInitial || state is ContactLoading) {
          return _Section(
            number: '',
            title: l10n.contact,
            child: const _ContactLoading(),
          );
        }

        if (state is ContactEmpty) {
          return _Section(
            number: '',
            title: l10n.contact,
            child: const _InlineMessage(
              text: 'Contact information is not available.',
            ),
          );
        }

        if (state is ContactError) {
          return _Section(
            number: '',
            title: l10n.contact,
            child: _InlineMessage(text: state.message),
          );
        }

        if (state is! ContactLoaded) {
          return _Section(
            number: '',
            title: l10n.contact,
            child: const _ContactLoading(),
          );
        }

        final contact = state.content;

        final title = contact.sectionTitle(languageCode).trim();
        final description = contact.sectionDescription(languageCode).trim();
        final buttonLabel = contact.sectionButton(languageCode).trim();

        final email = contact.email.trim();
        final phone = contact.phone.trim();

        return _Section(
          number: '',
          title: title.isNotEmpty ? title : l10n.contact,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A strong, quiet ending: the section description (already
              // modeled in Firestore, previously unused in this widget)
              // reads as the closing statement, with email/button as the
              // direct call to action — composition, not oversized type.
              if (description.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .72),
                      fontSize: AppTypography.body(context),
                      height: AppTypography.bodyLineHeight(context),
                    ),
                  ),
                ),
              if (description.isNotEmpty) const SizedBox(height: AppSpacing.xl),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.md,
                children: [
                  if (email.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () => _openEmail(email),
                      icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                      label: Text(
                        buttonLabel.isNotEmpty ? buttonLabel : email,
                        style: const TextStyle(
                          fontSize: AppTypography.button,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  _SocialLinksFooter(
                    github: contact.github.trim(),
                    instagram: contact.instagram.trim(),
                    linkedin: contact.linkedin.trim(),
                    email: email,
                    phone: phone,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SOCIAL LINKS FOOTER                                                        */
/* -------------------------------------------------------------------------- */

class _SocialLinksFooter extends StatelessWidget {
  const _SocialLinksFooter({
    required this.github,
    required this.instagram,
    required this.linkedin,
    required this.email,
    required this.phone,
  });

  final String github;
  final String instagram;
  final String linkedin;
  final String email;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final links = <Widget>[];

    if (github.isNotEmpty) {
      links.add(
        _FooterSocialIcon(
          tooltip: 'GitHub',
          assetPath: 'assets/icons/github.svg',
          onTap: () => _open(github),
        ),
      );
    }

    if (instagram.isNotEmpty) {
      links.add(
        _FooterSocialIcon(
          tooltip: 'Instagram',
          assetPath: 'assets/icons/instagram.svg',
          onTap: () => _open(instagram),
        ),
      );
    }

    if (linkedin.isNotEmpty) {
      links.add(
        _FooterSocialIcon(
          tooltip: 'LinkedIn',
          assetPath: 'assets/icons/linkedin.svg',
          onTap: () => _open(linkedin),
        ),
      );
    }

    if (email.isNotEmpty) {
      links.add(
        _FooterSocialIcon(
          tooltip: 'Email',
          icon: Icons.mail_outline_rounded,
          onTap: () => _openEmail(email),
        ),
      );
    }

    if (phone.isNotEmpty) {
      links.add(
        _FooterSocialIcon(
          tooltip: 'Phone',
          icon: Icons.phone_outlined,
          onTap: () => _openPhone(phone),
        ),
      );
    }

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: links,
    );
  }
}

class _FooterSocialIcon extends StatefulWidget {
  const _FooterSocialIcon({
    required this.tooltip,
    required this.onTap,
    this.icon,
    this.assetPath,
  });

  final String tooltip;
  final IconData? icon;
  final String? assetPath;
  final VoidCallback onTap;

  @override
  State<_FooterSocialIcon> createState() => _FooterSocialIconState();
}

class _FooterSocialIconState extends State<_FooterSocialIcon> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = hover
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: .48);

    return Semantics(
      button: true,
      label: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          if (!mounted) return;

          setState(() => hover = true);
        },
        onExit: (_) {
          if (!mounted) return;

          setState(() => hover = false);
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(50),
            splashColor: theme.colorScheme.primary.withValues(alpha: .12),
            highlightColor: theme.colorScheme.primary.withValues(alpha: .06),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: widget.assetPath != null
                    ? SvgPicture.asset(
                        widget.assetPath!,
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      )
                    : Icon(widget.icon, size: 18, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactLoading extends StatelessWidget {
  const _ContactLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* FOOTER                                                                     */
/* -------------------------------------------------------------------------- */

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    final theme = Theme.of(context);

    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        if (state is! ContactLoaded) {
          return const SizedBox.shrink();
        }

        final contact = state.content;

        final copyright = contact.footerCopyright(languageCode).trim();

        final builtWith = contact.footerBuiltWith(languageCode).trim();

        if (copyright.isEmpty && builtWith.isEmpty) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 700;

            final style = theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: .45),
              fontSize: AppTypography.meta(context),
              height: 1.5,
            );

            return Column(
              children: [
                Divider(
                  color: theme.colorScheme.outline.withValues(alpha: .30),
                  height: 1,
                ),
                const SizedBox(height: 18),
                if (mobile)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (copyright.isNotEmpty)
                        Text(
                          copyright,
                          textAlign: TextAlign.center,
                          style: style,
                        ),
                      if (builtWith.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            builtWith,
                            textAlign: TextAlign.center,
                            style: style,
                          ),
                        ),
                    ],
                  )
                else
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 24,
                    runSpacing: 8,
                    children: [
                      if (copyright.isNotEmpty) Text(copyright, style: style),
                      if (builtWith.isNotEmpty) Text(builtWith, style: style),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SECTION                                                                    */
/* -------------------------------------------------------------------------- */

class _Section extends StatelessWidget {
  const _Section({
    required this.number,
    required this.title,
    required this.child,
  });

  final String number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Section rhythm: consistent top/bottom breathing room from the shared
    // spacing scale rather than a one-off number, so every section (About,
    // Projects, Skills, Contact) feels like the same visual system.
    final topPadding = Responsive.isMobile(context)
        ? AppSpacing.xxxl
        : AppSpacing.xxxxl;

    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (number.isNotEmpty) ...[
                Text(
                  number,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: AppTypography.meta(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: AppTypography.sectionHeading(context),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Divider(
                  color: theme.colorScheme.outline.withValues(alpha: .5),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SIDE RAIL                                                                  */
/* -------------------------------------------------------------------------- */

class _SideRail extends StatelessWidget {
  const _SideRail();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      left: width > 1450 ? 34 : 16,
      bottom: 28,
      child: ValueListenableBuilder<String>(
        valueListenable: HomeNavbar.activeSection,
        builder: (context, active, child) {
          final label = switch (active) {
            'about' => l10n.about,
            'projects' => l10n.projects,
            'skills' => l10n.skills,
            'contact' => l10n.contact,
            _ => l10n.home,
          };

          return Column(
            children: [
              Container(
                width: 1,
                height: 85,
                color: Theme.of(context).colorScheme.outline,
              ),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* REVEAL                                                                     */
/* -------------------------------------------------------------------------- */

class _Reveal extends StatefulWidget {
  const _Reveal({required this.child, this.delay = 0});

  final Widget child;
  final int delay;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );

  late final Animation<double> opacity = CurvedAnimation(
    parent: controller,
    curve: const Cubic(0.645, 0.045, 0.355, 1.0),
  );

  late final Animation<Offset> slide = Tween<Offset>(
    begin: const Offset(0, .12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(position: slide, child: widget.child),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* LOADING / ERROR                                                            */
/* -------------------------------------------------------------------------- */

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 700,
      child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
    );
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.message, required this.retry});

  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextButton(
              onPressed: retry,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Text(text),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* PROJECT LOADING                                                            */
/* -------------------------------------------------------------------------- */

class _ProjectLoadingRows extends StatelessWidget {
  const _ProjectLoadingRows();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 2; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SKILL LOADING                                                              */
/* -------------------------------------------------------------------------- */

class _SkillLoading extends StatelessWidget {
  const _SkillLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* CONTACT ACTIONS                                                            */
/* -------------------------------------------------------------------------- */

Future<void> _openEmail(String email) async {
  final cleanEmail = email.trim();

  if (cleanEmail.isEmpty) return;

  final uri = Uri(scheme: 'mailto', path: cleanEmail);

  try {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  } catch (error, stackTrace) {
    debugPrint('Failed to open email: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> _openPhone(String phone) async {
  final cleanPhone = phone.trim();

  if (cleanPhone.isEmpty) return;

  final uri = Uri(scheme: 'tel', path: cleanPhone);

  try {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  } catch (error, stackTrace) {
    debugPrint('Failed to open phone: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> _open(String value) async {
  final uri = Uri.tryParse(value.trim());

  if (uri != null) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}
