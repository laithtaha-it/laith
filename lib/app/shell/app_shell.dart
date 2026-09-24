import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/locale_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../features/home/presentation/widgets/home_navbar.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _MobileDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 10 || constraints.maxHeight < 10) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              const SafeArea(bottom: false, child: HomeNavbar()),

              Expanded(child: child),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// MOBILE DRAWER
// ============================================================

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer();

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;

    final currentLocation = uri.path;
    final currentFragment = uri.fragment;

    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(name: l10n.appName),

            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                children: [
                  // ==================================================
                  // HOME
                  // ==================================================
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: l10n.home,
                    route: '/',
                    currentLocation: currentLocation,
                    currentFragment: currentFragment,
                  ),

                  // ==================================================
                  // ABOUT
                  // ==================================================
                  _DrawerItem(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: l10n.about,
                    route: '/#about',
                    currentLocation: currentLocation,
                    currentFragment: currentFragment,
                  ),

                  // ==================================================
                  // SKILLS
                  // ==================================================
                  _DrawerItem(
                    icon: Icons.code_outlined,
                    selectedIcon: Icons.code,
                    label: l10n.skills,
                    route: '/#skills',
                    currentLocation: currentLocation,
                    currentFragment: currentFragment,
                  ),

                  // ==================================================
                  // PROJECTS
                  // ==================================================
                  _DrawerItem(
                    icon: Icons.work_outline,
                    selectedIcon: Icons.work,
                    label: l10n.projects,
                    route: '/projects',
                    currentLocation: currentLocation,
                    currentFragment: currentFragment,
                  ),

                  // ==================================================
                  // CONTACT
                  // ==================================================
                  _DrawerItem(
                    icon: Icons.mail_outline,
                    selectedIcon: Icons.mail,
                    label: l10n.contact,
                    route: '/#contact',
                    currentLocation: currentLocation,
                    currentFragment: currentFragment,
                  ),

                  // ==================================================
                  // LOGIN
                  // ==================================================
                  ListTile(
                    leading: const Icon(Icons.login_rounded),
                    title: Text(l10n.login),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();

                      context.go('/admin/login');
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            const _DrawerLanguageButton(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DRAWER HEADER
// ============================================================

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const SizedBox(width: 14),

          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DRAWER ITEM
// ============================================================

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    required this.currentLocation,
    required this.currentFragment,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final String currentLocation;
  final String currentFragment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isHome = route == '/';
    final isSection = route.contains('#');

    final fragment = isSection ? route.split('#').last : '';

    // ==========================================================
    // SELECTED STATE
    // ==========================================================

    final bool isSelected;

    if (isHome) {
      isSelected = currentLocation == '/' && currentFragment.isEmpty;
    } else if (isSection) {
      isSelected = currentLocation == '/' && currentFragment == fragment;
    } else {
      isSelected =
          currentLocation == route || currentLocation.startsWith('$route/');
    }

    // ==========================================================
    // ITEM
    // ==========================================================

    return ListTile(
      selected: isSelected,

      leading: Icon(
        isSelected ? selectedIcon : icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),

      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),

      onTap: () {
        Navigator.of(context).pop();

        // ======================================================
        // HOME SECTION
        // ======================================================
        //
        // We ALWAYS use GoRouter.
        //
        // From:
        //
        // /projects/my-project
        //
        // to:
        //
        // /#skills
        //
        // HomePage then handles the scroll.
        //
        if (isSection) {
          context.go('/#$fragment');
          return;
        }

        // ======================================================
        // NORMAL ROUTE
        // ======================================================

        context.go(route);
      },
    );
  }
}

// ============================================================
// LANGUAGE BUTTON
// ============================================================

class _DrawerLanguageButton extends StatelessWidget {
  const _DrawerLanguageButton();

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            final cubit = context.read<LocaleCubit>();

            if (locale.languageCode == 'ar') {
              cubit.setEnglish();
            } else {
              cubit.setArabic();
            }
          },
          icon: const Icon(Icons.language, size: 20),
          label: Text(locale.languageCode == 'ar' ? 'English' : 'العربية'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
