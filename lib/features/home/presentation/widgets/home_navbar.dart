import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../l10n/app_localizations.dart';

class HomeNavbar extends StatelessWidget {
  const HomeNavbar({super.key});

  // --------------------------------------------------------------------------
  // ACTIVE SECTION
  // --------------------------------------------------------------------------

  static final ValueNotifier<String> activeSection = ValueNotifier<String>(
    'home',
  );

  static void setActiveSection(String section) {
    if (activeSection.value != section) {
      activeSection.value = section;
    }
  }

  // --------------------------------------------------------------------------
  // DIRECT HOME SECTION NAVIGATION
  // --------------------------------------------------------------------------
  //
  // HomePage owns the ScrollController, so the actual scroll must happen
  // there. This callback lets the navbar request the scroll directly instead
  // of relying only on GoRouter fragment lifecycle changes.
  //

  static void Function(String section)? onSectionNavigate;

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final mobile = width < AppBreakpoints.mobile;
    final tablet = width < AppBreakpoints.tablet;

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final uri = GoRouterState.of(context).uri;

    final currentPath = uri.path;
    final currentFragment = uri.fragment;

    final routeActiveSection = _routeActiveSection(
      currentPath,
      currentFragment,
    );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: mobile ? 70 : 82,
          padding: EdgeInsets.symmetric(
            horizontal: mobile
                ? 20
                : tablet
                ? 28
                : 50,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: .92),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: .45),
              ),
            ),
          ),
          child: Row(
            children: [
              // ----------------------------------------------------------------
              // BRAND
              // ----------------------------------------------------------------
              _Brand(name: l10n.appName),

              const Spacer(),

              // ----------------------------------------------------------------
              // MOBILE
              // ----------------------------------------------------------------
              if (mobile)
                Builder(
                  builder: (context) {
                    return IconButton(
                      tooltip: l10n.menu,
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(Icons.menu_rounded),
                    );
                  },
                )
              // ----------------------------------------------------------------
              // DESKTOP / TABLET
              // ----------------------------------------------------------------
              else ...[
                ValueListenableBuilder<String>(
                  valueListenable: activeSection,
                  builder: (context, active, child) {
                    final effectiveActive = routeActiveSection ?? active;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ABOUT
                        _NavItem(
                          number: '',
                          label: l10n.about,
                          section: 'about',
                          active: effectiveActive,
                          onTap: () {
                            _goSection(context, 'about');
                          },
                        ),

                        // PROJECTS
                        _NavItem(
                          number: '  ',
                          label: l10n.projects,
                          section: 'projects',
                          active: effectiveActive,
                          onTap: () {
                            _goSection(context, 'projects');
                          },
                        ),

                        // SKILLS
                        _NavItem(
                          number: '',
                          label: l10n.skills,
                          section: 'skills',
                          active: effectiveActive,
                          onTap: () {
                            _goSection(context, 'skills');
                          },
                        ),

                        // CONTACT
                        _NavItem(
                          number: '',
                          label: l10n.contact,
                          section: 'contact',
                          active: effectiveActive,
                          onTap: () {
                            _goSection(context, 'contact');
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(width: 18),

                // ----------------------------------------------------------------
                // SEPARATOR
                // ----------------------------------------------------------------
                Container(
                  width: 1,
                  height: 28,
                  color: theme.colorScheme.outline.withValues(alpha: .55),
                ),

                const SizedBox(width: 12),

                // ----------------------------------------------------------------
                // CV
                // ----------------------------------------------------------------
                _TopAction(
                  label: l10n.cv,
                  onTap: () {
                    context.go('/cv');
                  },
                ),

                // ----------------------------------------------------------------
                // ADMIN / LOGIN
                // ----------------------------------------------------------------
                _TopAction(
                  label: currentPath.startsWith('/admin')
                      ? l10n.admin
                      : l10n.login,
                  onTap: () {
                    context.go('/admin/login');
                  },
                ),

                // ----------------------------------------------------------------
                // LANGUAGE
                // ----------------------------------------------------------------
                const _LanguageAction(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ROUTE -> ACTIVE SECTION
  // --------------------------------------------------------------------------

  static String? _routeActiveSection(String path, String fragment) {
    if (path == '/') {
      if (fragment.isNotEmpty &&
          const {'about', 'projects', 'skills', 'contact'}.contains(fragment)) {
        return fragment;
      }

      return null;
    }

    if (path == '/projects' || path.startsWith('/projects/')) {
      return 'projects';
    }

    return null;
  }

  // --------------------------------------------------------------------------
  // SECTION NAVIGATION
  // --------------------------------------------------------------------------

  static void _goSection(BuildContext context, String section) {
    final uri = GoRouterState.of(context).uri;

    // Update navbar active state immediately.
    setActiveSection(section);

    // ------------------------------------------------------------------------
    // IMPORTANT
    // ------------------------------------------------------------------------
    //
    // Tell HomePage directly to scroll.
    //
    // This is intentionally called BEFORE the same-fragment check so that:
    //
    // /#projects
    //
    // can still scroll to Projects again if the user has manually moved away
    // from that section.
    //
    onSectionNavigate?.call(section);

    // If we are already on Home with this exact fragment, there is no need
    // to navigate again. HomePage has already received the direct callback.
    if (uri.path == '/' && uri.fragment == section) {
      return;
    }

    // Otherwise update the URL and navigate to Home + fragment.
    context.go('/#$section');
  }
}

// ============================================================================
// BRAND
// ============================================================================

class _Brand extends StatelessWidget {
  const _Brand({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go('/');
        },
        child: Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: .1,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NAV ITEM
// ============================================================================

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.number,
    required this.label,
    required this.section,
    required this.active,
    required this.onTap,
  });

  final String number;
  final String label;
  final String section;
  final String active;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool hover = false;

  bool get isActive => widget.active == widget.section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = isActive || hover
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: .72);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!mounted) return;

        setState(() {
          hover = true;
        });
      },
      onExit: (_) {
        if (!mounted) return;

        setState(() {
          hover = false;
        });
      },
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: theme.colorScheme.primary.withValues(alpha: .08),
        highlightColor: theme.colorScheme.primary.withValues(alpha: .04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                style: TextStyle(
                  color: color,
                  fontSize: AppTypography.navItem,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: .1,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.number.isNotEmpty)
                      Text(
                        widget.number,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(widget.label),
                  ],
                ),
              ),

              // ------------------------------------------------------------
              // QUIET ACTIVE INDICATOR
              // ------------------------------------------------------------
              //
              // A 1.5px underline that fades/slides in on active or hover
              // instead of a heavier pill/background — "clear but not
              // annoying" per the design brief.
              //
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 1.5,
                width: isActive || hover ? 16 : 0,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TOP ACTION
// ============================================================================

class _TopAction extends StatefulWidget {
  const _TopAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_TopAction> createState() => _TopActionState();
}

class _TopActionState extends State<_TopAction> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = hover
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: .72);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!mounted) return;

        setState(() {
          hover = true;
        });
      },
      onExit: (_) {
        if (!mounted) return;

        setState(() {
          hover = false;
        });
      },
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              color: color,
              fontSize: AppTypography.button,
              fontWeight: FontWeight.w600,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LANGUAGE
// ============================================================================

class _LanguageAction extends StatelessWidget {
  const _LanguageAction();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeCubit = context.read<LocaleCubit>();

    final currentLocale = Localizations.localeOf(context);

    final isArabic = currentLocale.languageCode == 'ar';

    final label = isArabic ? 'EN' : 'AR';

    return Tooltip(
      message: isArabic ? 'Switch to English' : 'التبديل إلى العربية',
      child: InkWell(
        onTap: () {
          localeCubit.toggleLocale();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: .72),
              fontSize: AppTypography.meta(context),
              fontWeight: FontWeight.w600,
              letterSpacing: .5,
            ),
          ),
        ),
      ),
    );
  }
}
