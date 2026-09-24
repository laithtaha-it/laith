import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/cv_locale_cubit.dart';
import '../core/localization/locale_cubit.dart';

// ============================================================
// COLORS
// ============================================================

import '../features/colors/data/datasources/colors_remote_data_source.dart';
import '../features/colors/data/repositories/colors_repository_impl.dart';
import '../features/colors/domain/entities/app_color_settings.dart';
import '../features/colors/domain/repositories/colors_repository.dart';
import '../features/colors/presentation/bloc/colors_cubit.dart';

// ============================================================
// CONTACT
// ============================================================

import '../features/contact/data/datasources/contact_remote_data_source.dart';
import '../features/contact/data/repositories/contact_repository_impl.dart';
import '../features/contact/domain/repositories/contact_repository.dart';

// ============================================================
// CV COLORS
// ============================================================

import '../features/cv_colors/data/datasources/cv_colors_remote_data_source.dart';
import '../features/cv_colors/data/repositories/cv_colors_repository_impl.dart';
import '../features/cv_colors/domain/repositories/cv_colors_repository.dart';
import '../features/cv_colors/presentation/bloc/cv_colors_cubit.dart';

// ============================================================
// HOME
// ============================================================

import '../features/home/data/datasources/home_remote_data_source.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/repositories/home_repository.dart';

// ============================================================
// PROJECTS
// ============================================================

import '../features/projects/data/datasources/project_remote_data_source.dart';
import '../features/projects/data/repositories/project_repository_impl.dart';
import '../features/projects/domain/repositories/project_repository.dart';

// ============================================================
// SKILLS
// ============================================================

import '../features/skills/data/datasources/skill_remote_data_source.dart';
import '../features/skills/data/repositories/skill_repository_impl.dart';
import '../features/skills/domain/repositories/skill_repository.dart';

// ============================================================
// APP
// ============================================================

import '../l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class AppDependencies {
  AppDependencies({required FirebaseFirestore firestore})
    : colorsRepository = ColorsRepositoryImpl(
        remoteDataSource: ColorsRemoteDataSource(firestore: firestore),
      ),
      cvColorsRepository = CvColorsRepositoryImpl(
        remoteDataSource: CvColorsRemoteDataSource(firestore: firestore),
      ),
      homeRepository = HomeRepositoryImpl(
        remoteDataSource: HomeRemoteDataSourceImpl(firestore: firestore),
      ),
      projectRepository = ProjectRepositoryImpl(
        remoteDataSource: ProjectRemoteDataSourceImpl(firestore: firestore),
      ),
      skillRepository = SkillRepositoryImpl(
        remoteDataSource: SkillRemoteDataSourceImpl(firestore: firestore),
      ),
      contactRepository = ContactRepositoryImpl(
        remoteDataSource: ContactRemoteDataSourceImpl(firestore: firestore),
      ) {
    router = AppRouter.create(
      homeRepository: homeRepository,
      projectRepository: projectRepository,
      skillRepository: skillRepository,
      contactRepository: contactRepository,
    );
  }

  final ColorsRepository colorsRepository;
  final CvColorsRepository cvColorsRepository;

  final HomeRepository homeRepository;
  final ProjectRepository projectRepository;
  final SkillRepository skillRepository;
  final ContactRepository contactRepository;

  late final GoRouter router;
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
        BlocProvider<CvLocaleCubit>(create: (_) => CvLocaleCubit()),

        // IMPORTANT:
        // Colors are intentionally NOT loaded here.
        // The first frame must render without waiting for Firestore.
        BlocProvider<ColorsCubit>(
          create: (_) => ColorsCubit(repository: dependencies.colorsRepository),
        ),

        // CV colors are also loaded after the first frame.
        BlocProvider<CvColorsCubit>(
          create: (_) =>
              CvColorsCubit(repository: dependencies.cvColorsRepository),
        ),
      ],
      child: _PortfolioAppView(router: dependencies.router),
    );
  }
}

class _PortfolioAppView extends StatefulWidget {
  const _PortfolioAppView({required this.router});

  final GoRouter router;

  @override
  State<_PortfolioAppView> createState() => _PortfolioAppViewState();
}

class _PortfolioAppViewState extends State<_PortfolioAppView> {
  bool _backgroundLoadsStarted = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBackgroundLoads();
    });
  }

  void _startBackgroundLoads() {
    if (_backgroundLoadsStarted || !mounted) {
      return;
    }

    _backgroundLoadsStarted = true;

    context.read<ColorsCubit>().load();
    context.read<CvColorsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.select<LocaleCubit, Locale>((cubit) => cubit.state);

    final colors = context.select<ColorsCubit, AppColorSettings>(
      (cubit) => cubit.state.colors,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Laith Taha',
      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(locale: locale, colors: colors),
      routerConfig: widget.router,
    );
  }
}
