import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// ============================================================
// HOME
// ============================================================

import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_content.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/bloc/home_event.dart';
import '../../features/home/presentation/pages/home_page.dart';

// ============================================================
// PROJECTS
// ============================================================

import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/usecases/get_featured_projects.dart';
import '../../features/projects/domain/usecases/get_project_by_id.dart';
import '../../features/projects/domain/usecases/get_projects.dart';
import '../../features/projects/presentation/bloc/project_bloc.dart';
import '../../features/projects/presentation/pages/project_details_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';

// ============================================================
// SKILLS
// ============================================================

import '../../features/skills/domain/repositories/skill_repository.dart';
import '../../features/skills/domain/usecases/get_skills.dart';
import '../../features/skills/presentation/bloc/skill_bloc.dart';

// ============================================================
// CONTACT
// ============================================================

import '../../features/contact/domain/repositories/contact_repository.dart';
import '../../features/contact/presentation/bloc/contact_bloc.dart';

// ============================================================
// ADMIN
// ============================================================

import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_gate_page.dart';
import '../../features/admin/presentation/pages/admin_login_page.dart';
import '../../features/admin/presentation/pages/admin_singleton_editor_page.dart';
import '../../features/admin/presentation/pages/admin_skills_page.dart';
import '../../features/admin/presentation/pages/admin_projects_page.dart';
import '../../features/cv/presentation/pages/admin_cv_page.dart';
import '../../features/colors/presentation/pages/admin_colors_page.dart';
import '../../features/cv_colors/presentation/pages/admin_cv_colors_page.dart';
import '../../features/cv/presentation/pages/cv_page.dart';

// ============================================================
// APP SHELL
// ============================================================

import '../shell/app_shell.dart';

class AppRouter {
  AppRouter._();

  // ============================================================
  // CREATE ROUTER
  //
  // Router receives already-created repositories.
  // It NEVER creates Firestore/DataSources/Repositories itself.
  // ============================================================

  static GoRouter create({
    required HomeRepository homeRepository,
    required ProjectRepository projectRepository,
    required SkillRepository skillRepository,
    required ContactRepository contactRepository,
  }) {
    return GoRouter(
      initialLocation: '/',

      // IMPORTANT:
      // Diagnostics are disabled for production.
      // They add unnecessary console work/logging.
      debugLogDiagnostics: false,

      routes: [
        // ========================================================
        // ADMIN ROUTES
        //
        // Deliberately NOT wrapped by AppShell.
        // ========================================================
        GoRoute(
          path: '/admin/login',
          name: 'adminLogin',
          builder: (context, state) => const AdminLoginPage(),
        ),

        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (context, state) =>
              const AdminGate(child: AdminDashboardPage()),
        ),

        GoRoute(
          path: '/admin/home',
          name: 'adminHome',
          builder: (context, state) => const AdminGate(
            child: AdminSingletonEditorPage(type: AdminEditorType.home),
          ),
        ),

        GoRoute(
          path: '/admin/about',
          name: 'adminAbout',
          builder: (context, state) => const AdminGate(
            child: AdminSingletonEditorPage(type: AdminEditorType.about),
          ),
        ),

        GoRoute(
          path: '/admin/skills',
          name: 'adminSkills',
          builder: (context, state) =>
              const AdminGate(child: AdminSkillsPage()),
        ),

        GoRoute(
          path: '/admin/projects',
          name: 'adminProjects',
          builder: (context, state) =>
              const AdminGate(child: AdminProjectsPage()),
        ),

        GoRoute(
          path: '/admin/cv',
          name: 'adminCv',
          builder: (context, state) => const AdminGate(child: AdminCvPage()),
        ),

        GoRoute(
          path: '/admin/colors',
          name: 'adminColors',
          builder: (context, state) =>
              const AdminGate(child: AdminColorsPage()),
        ),

        GoRoute(
          path: '/admin/cv-colors',
          name: 'adminCvColors',
          builder: (context, state) =>
              const AdminGate(child: AdminCvColorsPage()),
        ),

        GoRoute(
          path: '/admin/contact',
          name: 'adminContact',
          builder: (context, state) => const AdminGate(
            child: AdminSingletonEditorPage(type: AdminEditorType.contact),
          ),
        ),

        // ========================================================
        // PUBLIC ROUTES
        // ========================================================
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) {
            return AppShell(
              child: _withHomeBlocs(
                homeRepository: homeRepository,
                projectRepository: projectRepository,
                skillRepository: skillRepository,
                contactRepository: contactRepository,
                child: const HomePage(),
              ),
            );
          },
        ),

        GoRoute(
          path: '/about',
          name: 'about',
          builder: (context, state) {
            return const AppShell(
              child: _PlaceholderPage(title: 'About', sectionFragment: 'about'),
            );
          },
        ),

        GoRoute(
          path: '/projects',
          name: 'projects',
          builder: (context, state) {
            return AppShell(
              child: _withProjectBloc(
                repository: projectRepository,
                child: const ProjectsPage(),
              ),
            );
          },
        ),

        GoRoute(
          path: '/projects/:id',
          name: 'projectDetails',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';

            return AppShell(
              child: _withProjectBloc(
                repository: projectRepository,
                child: ProjectDetailsPage(projectId: id),
              ),
            );
          },
        ),

        GoRoute(
          path: '/cv',
          name: 'cv',
          builder: (context, state) => const CvPage(),
        ),

        GoRoute(
          path: '/contact',
          name: 'contact',
          builder: (context, state) {
            return const AppShell(
              child: _PlaceholderPage(
                title: 'Contact',
                sectionFragment: 'contact',
              ),
            );
          },
        ),
      ],

      // ==========================================================
      // ERROR PAGE
      // ==========================================================
      errorBuilder: (context, state) {
        return const AppShell(child: _PlaceholderPage(title: 'Page Not Found'));
      },
    );
  }

  // ============================================================
  // HOME BLOCS
  //
  // IMPORTANT:
  // Repositories are injected.
  //
  // Home loads immediately.
  // Projects / Skills / Contact are created only.
  // Their actual loading is triggered by HomePage.
  // ============================================================

  static Widget _withHomeBlocs({
    required HomeRepository homeRepository,
    required ProjectRepository projectRepository,
    required SkillRepository skillRepository,
    required ContactRepository contactRepository,
    required Widget child,
  }) {
    return MultiBlocProvider(
      providers: [
        // ========================================================
        // HOME
        //
        // Critical data.
        // The HomeBloc starts loading immediately.
        // ========================================================
        BlocProvider<HomeBloc>(
          create: (_) {
            return HomeBloc(getHomeContent: GetHomeContent(homeRepository))
              ..add(const LoadHomeContent());
          },
        ),

        // ========================================================
        // PROJECTS
        //
        // Created only.
        // No Firestore request here.
        //
        // HomePage decides when featured projects are needed.
        // ========================================================
        BlocProvider<ProjectBloc>(
          create: (_) {
            return ProjectBloc(
              getProjects: GetProjects(projectRepository),
              getFeaturedProjects: GetFeaturedProjects(projectRepository),
              getProjectById: GetProjectById(projectRepository),
            );
          },
        ),

        // ========================================================
        // SKILLS
        //
        // Created only.
        // No Firestore request here.
        // ========================================================
        BlocProvider<SkillBloc>(
          create: (_) {
            return SkillBloc(getSkills: GetSkills(skillRepository));
          },
        ),

        // ========================================================
        // CONTACT
        //
        // Created only.
        // No Firestore request here.
        // ========================================================
        BlocProvider<ContactBloc>(
          create: (_) {
            return ContactBloc(repository: contactRepository);
          },
        ),
      ],
      child: child,
    );
  }

  // ============================================================
  // PROJECT BLOC
  // ============================================================

  static Widget _withProjectBloc({
    required ProjectRepository repository,
    required Widget child,
  }) {
    return BlocProvider<ProjectBloc>(
      create: (_) {
        return ProjectBloc(
          getProjects: GetProjects(repository),
          getFeaturedProjects: GetFeaturedProjects(repository),
          getProjectById: GetProjectById(repository),
        );
      },
      child: child,
    );
  }
}

// ================================================================
// PLACEHOLDER PAGE
// ================================================================
//
// Reached only via a direct/external URL to /about, /contact, or an
// unknown path — nothing inside this app links here (About/Contact are
// normally sections on Home). Rather than leave a bare, dead-end label,
// this offers a real way back in, styled with the shared design tokens.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, this.sectionFragment});

  final String title;

  /// When set (about/contact), the CTA sends the visitor to that section
  /// on Home instead of just Home itself.
  final String? sectionFragment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final fragment = sectionFragment;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () {
                  context.go(fragment != null ? '/#$fragment' : '/');
                },
                icon: Icon(
                  isArabic
                      ? Icons.arrow_forward_rounded
                      : Icons.arrow_back_rounded,
                  size: 18,
                ),
                label: Text(isArabic ? 'العودة للرئيسية' : 'Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
