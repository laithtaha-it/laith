import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScaffold extends StatelessWidget {
  const AdminScaffold({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  static const double _drawerBreakpoint = 760;
  static const double _extendedRailBreakpoint = 1100;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final items = <_AdminNavItem>[
      const _AdminNavItem('Overview', '/admin'),
      const _AdminNavItem('Home', '/admin/home'),
      const _AdminNavItem('About', '/admin/about'),
      const _AdminNavItem('Skills', '/admin/skills'),
      const _AdminNavItem('Projects', '/admin/projects'),
      const _AdminNavItem('CV', '/admin/cv'),
      const _AdminNavItem('COLORS', '/admin/colors'),
      const _AdminNavItem('CV COLORS', '/admin/cv-colors'),
      const _AdminNavItem('Contact', '/admin/contact'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final useDrawer = width < _drawerBreakpoint;
        final extendedRail = width >= _extendedRailBreakpoint;
        final selectedIndex = _selectedIndex(location);

        return Scaffold(
          drawer: useDrawer
              ? _AdminDrawer(
                  items: items,
                  selectedIndex: selectedIndex,
                  onSelected: (index) {
                    Navigator.of(context).pop();
                    Future<void>.delayed(Duration.zero, () {
                      if (context.mounted) context.go(items[index].path);
                    });
                  },
                )
              : null,
          body: Row(
            children: [
              if (!useDrawer) ...[
                NavigationRail(
                  extended: extendedRail,
                  minExtendedWidth: 220,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => context.go(items[index].path),
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
              ],
              Expanded(
                child: Column(
                  children: [
                    AppBar(
                      automaticallyImplyLeading: false,
                      leading: useDrawer
                          ? Builder(
                              builder: (context) => IconButton(
                                tooltip: 'Open menu',
                                onPressed: () => Scaffold.of(context).openDrawer(),
                                icon: const Icon(Icons.menu),
                              ),
                            )
                          : null,
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      actions: [
                        IconButton(
                          tooltip: 'Back to website',
                          onPressed: () => context.go('/'),
                          icon: const Icon(Icons.open_in_new),
                        ),
                        IconButton(
                          tooltip: 'Sign out',
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) context.go('/admin/login');
                          },
                          icon: const Icon(Icons.logout),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _selectedIndex(String path) {
    if (path == '/admin') return 0;
    if (path.startsWith('/admin/home')) return 1;
    if (path.startsWith('/admin/about')) return 2;
    if (path.startsWith('/admin/skills')) return 3;
    if (path.startsWith('/admin/projects')) return 4;
    if (path == '/admin/cv' || path.startsWith('/admin/cv/')) return 5;
    if (path.startsWith('/admin/colors')) return 6;
    if (path.startsWith('/admin/cv-colors')) return 7;
    if (path.startsWith('/admin/contact')) return 8;
    return 0;
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_AdminNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.dashboard_outlined),
              title: Text(
                'Admin Dashboard',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    selected: index == selectedIndex,
                    leading: Icon(item.icon),
                    title: Text(item.label),
                    onTap: () => onSelected(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminNavItem {
  const _AdminNavItem(this.label, this.path);

  final String label;
  final String path;

  IconData get icon => switch (path) {
        '/admin' => Icons.dashboard_outlined,
        '/admin/home' => Icons.home_outlined,
        '/admin/about' => Icons.person_outline,
        '/admin/skills' => Icons.code_outlined,
        '/admin/projects' => Icons.work_outline,
        '/admin/cv' => Icons.description_outlined,
        '/admin/colors' => Icons.palette_outlined,
        '/admin/cv-colors' => Icons.color_lens_outlined,
        '/admin/contact' => Icons.contact_mail_outlined,
        _ => Icons.circle_outlined,
      };
}
