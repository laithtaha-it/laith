// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Laith Taha';

  @override
  String get appDescription => 'Flutter Developer & Software Engineer';

  @override
  String get home => 'Home';

  @override
  String get about => 'About';

  @override
  String get skills => 'Skills';

  @override
  String get projects => 'Projects';

  @override
  String get contact => 'Contact';

  @override
  String get viewProjects => 'View Projects';

  @override
  String get getInTouch => 'Get in Touch';

  @override
  String get learnMore => 'Learn More';

  @override
  String get projectTechnologies => 'Technologies';

  @override
  String get projectGithub => 'GitHub';

  @override
  String get projectLive => ' link ';

  @override
  String get projectNotFound => 'Project not found';

  @override
  String get noProjects => 'No projects available';

  @override
  String get backToProjects => 'Back to Projects';

  @override
  String get retry => 'Retry';

  @override
  String get projectGallery => 'Gallery';

  @override
  String heroGreeting(Object name) {
    return 'Hi, my name is $name.';
  }

  @override
  String get viewCv => 'View my CV';

  @override
  String get login => 'Login';

  @override
  String get admin => 'Admin';

  @override
  String get menu => 'Menu';

  @override
  String get cv => 'CV';
}
